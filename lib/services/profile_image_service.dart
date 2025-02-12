import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage.ref().child('profile_images/${user.uid}');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  Future<String?> getProfileImageUrl() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage.ref().child('profile_images/${user.uid}');
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting profile image: $e');
      return null;
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final ref = _storage.ref().child('profile_images/${user.uid}');
      await ref.delete();
    } catch (e) {
      print('Error deleting profile image: $e');
    }
  }
}
