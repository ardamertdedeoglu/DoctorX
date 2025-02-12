import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
