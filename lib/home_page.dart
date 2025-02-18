import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'models/user_model.dart';
import 'main.dart';
import 'generated/l10n.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/profile_image_service.dart';
import 'package:image_picker/image_picker.dart';
import 'models/role_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MyHomePage(title: 'DoctorX'),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  final ProfileImageService _profileImageService = ProfileImageService();
  final ImagePicker picker = ImagePicker();

  Future<void> _saveImage(String imagePath) async {
    try {
      // Upload image and get URL
      final imageFile = File(imagePath);
      final imageUrl = await _profileImageService.uploadProfileImage(imageFile);

      // Update user model
      final updatedUser = UserModel(
        id: _userData?.id,
        role: _userData!.role,
        firstName: _userData!.firstName,
        lastName: _userData!.lastName,
        email: _userData?.email ?? '',
        accountType: _userData?.accountType,
        linkedAccounts: _userData?.linkedAccounts,
        profileImageUrl: imageUrl,
      );

      // Update Firestore
      if (_userData?.id != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userData!.id)
            .update({'profileImageUrl': imageUrl});

        // Update local state
        setState(() {
          _userData = updatedUser;
        });

        // Update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(updatedUser.toJson()));
      }
    } catch (e) {
      print("Error saving profile image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile image')),
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user_data');
      
      // Kullanıcı verisini yüklerken geçen süreyi azaltmak için
      // mounted kontrolü yapalım ve setState'i optimize edelim
      if (!mounted) return;
      
      setState(() {
        if (userStr != null) {
          _userData = UserModel.fromJson(jsonDecode(userStr));
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteProfileImage() async {
    try {
      // Firebase Storage'dan fotoğrafı sil
      await _profileImageService.deleteProfileImage();

      // UserModel'i güncelle
      final updatedUser = UserModel(
        id: _userData?.id,
        role: _userData!.role,
        firstName: _userData!.firstName,
        lastName: _userData!.lastName,
        email: _userData?.email ?? '',
        accountType: _userData?.accountType,
        linkedAccounts: _userData?.linkedAccounts,
        profileImageUrl: null, // Profil fotoğrafı URL'ini null yap
      );

      // Firestore'u güncelle
      if (_userData?.id != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userData!.id)
            .update({'profileImageUrl': null});

        // Local state'i güncelle
        setState(() {
          _userData = updatedUser;
        });

        // SharedPreferences'ı güncelle
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(updatedUser.toJson()));
      }
    } catch (e) {
      print("Error deleting profile image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil fotoğrafı silinirken bir hata oluştu')),
      );
    }
  }

  Future<void> _showImageSourceSheet() {
    return showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text(S.of(context).chooseFromGalleryButton),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  _saveImage(pickedFile.path);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text(S.of(context).cameraButton),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  _saveImage(pickedFile.path);
                }
              },
            ),
            if (_userData?.profileImageUrl != null) // Sadece fotoğraf varsa göster
              ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red),
                title: Text(
                  S.of(context).removePhotoButton,
                  style: TextStyle(color: Colors.red)
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _deleteProfileImage(); // _deleteProfileImage'i burada kullan
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final isDoctor = _userData?.role == UserRole.doctor; // Add this line
    
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).homePageTitle),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isLoading)
              CircularProgressIndicator()
            else ...[
              Text(
                _userData != null
                    ? '${S.of(context).welcomeMessage}, ${isDoctor ? 'Dr. ' : ''}${_userData!.firstName}!' // Modified this line
                    : S.of(context).welcomeMessage,
                style: TextStyle(
                  fontSize: 24,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                S.of(context).preparingApp,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}