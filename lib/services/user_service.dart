import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcı verilerini senkronize et
  Future<void> syncUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Firestore'dan kullanıcı verilerini al
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return;

      final userData = UserModel.fromJson(doc.data()!);

      // SharedPreferences'a kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(userData.toJson()));
    } catch (e) {
      print('Error syncing user data: $e');
    }
  }

  // Kullanıcı verilerini güncelle
  Future<void> updateUserData(UserModel userData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Firestore'u güncelle
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(userData.toJson());

      // SharedPreferences'ı güncelle
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(userData.toJson()));
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }
}
