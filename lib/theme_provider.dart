import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromFirebase();
  }

  Future<void> _loadThemeFromFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _isDarkMode = doc.data()?['isDarkMode'] ?? false;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  Future<void> setTheme(bool isDark) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'isDarkMode': isDark,
        });
        _isDarkMode = isDark;
        notifyListeners();
      }
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  void toggleTheme() {
    setTheme(!_isDarkMode);
  }
}
