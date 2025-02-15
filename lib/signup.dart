import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _handleSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          final user = UserModel(
            id: userCredential.user?.uid,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
          );

          // Firestore'a kaydet
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user?.uid)
              .set(user.toJson());

          // SharedPreferences'a kaydet
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode(user.toJson()));
          
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).signup)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: S.of(context).firstName,
                border: OutlineInputBorder(),
              ),
              validator: (value) => 
                value?.isEmpty ?? true ? S.of(context).requiredField : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: S.of(context).lastName,
                border: OutlineInputBorder(),
              ),
              validator: (value) => 
                value?.isEmpty ?? true ? S.of(context).requiredField : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: S.of(context).emailLabel,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return S.of(context).requiredField;
                }
                if (!value!.contains('@')) {
                  return S.of(context).invalidEmailMessage;
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: S.of(context).password,
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => 
                    _isPasswordVisible = !_isPasswordVisible
                  ),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return S.of(context).requiredField;
                }
                if ((value?.length ?? 0) < 6) {
                  return S.of(context).passwordMinLength;
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: S.of(context).verifyPassword,
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible 
                        ? Icons.visibility 
                        : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => 
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible
                  ),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return S.of(context).requiredField;
                }
                if (value != _passwordController.text) {
                  return S.of(context).passwordsNotMatch;
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSignup,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isLoading 
                  ? CircularProgressIndicator()
                  : Text(S.of(context).signup),
            ),
          ],
        ),
      ),
    );
  }
}