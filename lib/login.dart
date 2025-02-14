import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'dart:convert'; // Import jsonEncode
import 'generated/l10n.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false; // Yeni değişken

  @override
  void initState() {
    super.initState();
    _loadSavedEmail(); // initState'de e-postayı yükle
  }

  Future<void> _loadSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Firebase'den kullanıcı verilerini kontrol et
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          setState(() {
            _rememberMe = userData['rememberMe'] ?? false;
            if (_rememberMe) {
              _emailController.text = userData['email'] ?? '';
            }
          });
        }
      } else {
        // Eğer Firebase oturumu yoksa, yerel depolamadan oku
        final savedEmail = prefs.getString('remembered_email') ?? '';
        setState(() {
          _emailController.text = savedEmail;
          _rememberMe = savedEmail.isNotEmpty;
        });
      }
    } catch (e) {
      print('Error loading saved email: $e');
    }
  }

  // Form validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).requiredEmail;
    }
    if (!value.contains('@')) {
      return S.of(context).invalidEmailMessage;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).requiredPassword;
    }
    if (value.length < 6) {
      return S.of(context).passwordMinLength;
    }
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1. Firebase Authentication ile giriş yap
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Firestore'dan kullanıcı verilerini al
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        // SharedPreferences'ı güncelle
        final prefs = await SharedPreferences.getInstance();
        
        // Beni Hatırla seçili ise e-postayı kaydet
        if (_rememberMe) {
          await prefs.setString('remembered_email', _emailController.text);
        }
        
        // Firestore'da rememberMe tercihini güncelle
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'rememberMe': _rememberMe});

        // 3. SharedPreferences'ı temizle ve yeni verileri kaydet
        await prefs.clear(); // Önceki tüm verileri temizle
        
        // Sadece login durumunu ve aktif kullanıcı verisini kaydet
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_data', jsonEncode(userDoc.data()));
        await prefs.setString('current_user_id', userCredential.user!.uid);

        // 4. Ana sayfaya yönlendir
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Bir hata oluştu';
      if (e.code == 'user-not-found') {
        message = S.of(context).userNotFound;
      } else if (e.code == 'wrong-password') {
        message = S.of(context).wrongPassword;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveEmailPreference() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Firestore'daki kullanıcı dokümanını güncelle
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'rememberMe': _rememberMe});
      
      // Eğer "Beni Hatırla" seçili değilse, kayıtlı e-postayı temizle
      if (!_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('remembered_email');
      }
    } catch (e) {
      print('Error saving remember me preference: $e');
    }
  }

  Future<void> _resetPassword() async {
    // Create a TextEditingController for the dialog
    final resetEmailController = TextEditingController();
    
    // Show dialog to get email
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).resetPasswordTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.of(context).emailForResettingPassword),
            SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              decoration: InputDecoration(
                labelText: S.of(context).emailLabel,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context).requiredEmail)),
                );
                return;
              }

              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                Navigator.pop(context); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context).resetLinkConfirmed)),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${S.of(context).resetLinkError} ${e.toString()}')),
                );
              }
            },
            child: Text('Gönder'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(S.of(context).login, style: TextStyle(fontSize: 24)),
              SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                validator: _validateEmail,
                decoration: InputDecoration(
                  labelText: S.of(context).emailLabel,
                  border: OutlineInputBorder(),
                ),
                //Klavyeyi e-posta moduna ayarla
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                validator: _validatePassword,
                obscureText: !_isPasswordVisible,  // Değişkene göre görünürlük
                decoration: InputDecoration(
                  labelText: S.of(context).password,
                  border: OutlineInputBorder(),
                  suffixIcon: GestureDetector(
                    onTapDown: (_) => setState(() => _isPasswordVisible = true),
                    onTapUp: (_) => setState(() => _isPasswordVisible = false),
                    onTapCancel: () => setState(() => _isPasswordVisible = false),
                    child: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      Text(S.of(context).rememberMe),
                    ],
                  ),
                  TextButton(
                    onPressed: _resetPassword,
                    child: Text(S.of(context).forgotPassword),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _isLoading 
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(S.of(context).login, 
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                  ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: Text(S.of(context).signupButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}