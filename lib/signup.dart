import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'widgets/account_type_dialog.dart'; // Import AccountTypeDialog
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'generated/l10n.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Yeni controller
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false; // Yeni değişken
  bool _isLoading = false;

  Future<void> _signup() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) { // Confirm password kontrolü
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).requiredAll)),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) { // Şifre kontrolü
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).passwordsNotMatch)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Firebase Authentication ile kullanıcı oluştur
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Kullanıcı başarıyla oluşturulduysa
      if (userCredential.user != null) {
        final prefs = await SharedPreferences.getInstance();
        
        // Kullanıcı bilgilerini kaydet
        final user = UserModel(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
        );

        await prefs.setString('user_data', jsonEncode(user.toJson()));
        await prefs.setString('user_email', _emailController.text);
        await prefs.setString('user_password', _passwordController.text);
        
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showError(S.of(context).weakPassword);
      } else if (e.code == 'email-already-in-use') {
        _showError(S.of(context).emailAlreadyInUse);
      } else {
        _showError('${S.of(context).signError} ${e.message}');
      }
    } catch (e) {
      _showError('${S.of(context).unexpectedError} ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Normal kayıt işlemleri...
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // Başarılı kayıt sonrası hesap türü seçimi göster
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AccountTypeDialog(
            onTypeSelected: (accountType) async {
              // Kullanıcı verisini güncelle
              final userModel = UserModel(
                id: userCredential.user!.uid,
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                email: _emailController.text,
                accountType: accountType,
                linkedAccounts: [],
              );

              // Firestore'a kaydet
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .set(userModel.toJson());
            },
          ),
        );
      } catch (e) {
        // Hata yönetimi...

      }
    }
  }

  // Çocuk hesabı oluşturma
  Future<void> _createChildAccount({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final userModel = UserModel(
        id: userCredential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        accountType: 'child', // Çocuk hesabı olarak işaretle
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toJson());

    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).signup)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: S.of(context).firstName,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: S.of(context).lastName,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: S.of(context).emailLabel,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
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
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController, // Confirm password alanı
              obscureText: !_isConfirmPasswordVisible, // Confirm password görünürlük
              decoration: InputDecoration(
                labelText: S.of(context).verifyPassword,
                border: OutlineInputBorder(),
                suffixIcon: GestureDetector(
                  onTapDown: (_) => setState(() => _isConfirmPasswordVisible = true),
                  onTapUp: (_) => setState(() => _isConfirmPasswordVisible = false),
                  onTapCancel: () => setState(() => _isConfirmPasswordVisible = false),
                  child: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _signup,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(S.of(context).signup),
            ),
          ],
        ),
      ),
    );
  }
}