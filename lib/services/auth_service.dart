import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctorx/models/user_model.dart';
import 'package:doctorx/models/role_model.dart';
import 'package:doctorx/generated/l10n.dart';
import 'package:flutter/material.dart';



class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _emailVerificationTimer;
  bool _hasShownVerification = false; // Yeni flag ekle

  void startEmailVerificationCheck(Function(bool) onVerificationComplete) {
    _emailVerificationTimer?.cancel();
    _emailVerificationTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified && !_hasShownVerification) {
          _hasShownVerification = true; // Flag'i güncelle
          timer.cancel();
          onVerificationComplete(true);
        }
      }
    });
  }

  void stopEmailVerificationCheck() {
    _emailVerificationTimer?.cancel();
  }

  // Email doğrulama durumunu kontrol et
  Future<bool> checkEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      _hasShownVerification = user.emailVerified; // Flag'i güncelle
      return user.emailVerified;
    }
    return false;
  }

  // Kullanıcı oturumunu kontrol et
  Future<bool> checkSession() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Firestore'dan güncel veriyi kontrol et
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        return userDoc.exists;
      }
      return false;
    } catch (e) {
      print("Error checking session: $e");
      return false;
    }
  }

  // Oturumu kapat
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Tüm local verileri temizle
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Future<List<UserModel>> getLinkedAccounts(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print("Error getting linked accounts: $e");
      return [];
    }
  }

  Future<UserModel?> createDoctorAccount(UserModel baseUser, {
    required String doctorTitle,
    required String specialization,
    required String licenseNumber,
    required String hospitalId,
    required BuildContext context, // Add context parameter
  }) async {
    try {
      // 1. Önce mevcut linkedAccounts listesini al
      final baseUserDoc = await _firestore.collection('users').doc(baseUser.id).get();
      List<String> currentLinkedAccounts = [];
      if (baseUserDoc.exists && baseUserDoc.data()?['linkedAccounts'] != null) {
        currentLinkedAccounts = List<String>.from(baseUserDoc.data()?['linkedAccounts'] ?? []);
      }

      // 2. Yeni doktor hesabı oluştur
      final docRef = await _firestore.collection('users').add({
        'email': baseUser.email,
        'firstName': baseUser.firstName,
        'lastName': baseUser.lastName,
        'role': 'UserRole.doctor',
        'accountType': 'doctor',
        'doctorTitle': doctorTitle,
        'specialization': specialization,
        'licenseNumber': licenseNumber,
        'originalAccountId': baseUser.id,
        'hospitalId': hospitalId,
        'profileImageUrl': baseUser.profileImageUrl,
        'linkedAccounts': [], // Boş array olarak başlat
      });

      // 3. Ana hesabın linkedAccounts listesini güncelle
      currentLinkedAccounts.add(docRef.id);
      await _firestore.collection('users').doc(baseUser.id).update({
        'linkedAccounts': currentLinkedAccounts
      });

      // 4. Oluşturulan doktor hesabının tam verisini al
      final newDoctorDoc = await docRef.get();
      if (!newDoctorDoc.exists) {
        throw Exception(S.of(context).newlyCreatedDoctorAccountNotFound);
      }

      // 5. UserModel nesnesini oluştur ve döndür
      return UserModel(
        id: docRef.id,
        role: UserRole.doctor,
        firstName: baseUser.firstName,
        lastName: baseUser.lastName,
        email: baseUser.email,
        accountType: 'doctor',
        doctorTitle: doctorTitle,
        specialization: specialization,
        licenseNumber: licenseNumber,
        originalAccountId: baseUser.id,
        hospitalId: hospitalId,
        profileImageUrl: baseUser.profileImageUrl,
        linkedAccounts: [],
      );
    } catch (e) {
      print("Error creating doctor account: $e");
      rethrow; // Hatayı yukarı fırlat
    }
  }
}
