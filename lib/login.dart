import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'dart:convert'; // Import jsonEncode
import 'generated/l10n.dart';
import 'services/auth_service.dart'; // Import AuthService
import 'models/user_model.dart'; // Import UserModel
import 'models/role_model.dart';
import 'models/hospital_model.dart';
import 'services/hospital_service.dart'; // Import HospitalService


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _authService = AuthService();
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

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        final accounts = await _authService.getLinkedAccounts(_emailController.text);
        
        if (accounts.length > 1) {
          // Birden fazla hesap varsa hesap seçme dialogunu göster
          if (!mounted) return;
          final selectedAccount = await _showAccountSelectionDialog(accounts);
          if (selectedAccount != null) {
            // Seçilen hesabı SharedPreferences'a kaydet
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_data', jsonEncode(selectedAccount.toJson()));
            
            if (!mounted) return;
            //doktor hesabı seçilirse doktor sayfasına yönlendir
            
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else if (accounts.isNotEmpty) {
          // Tek hesap varsa direkt o hesapla devam et
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode(accounts.first.toJson()));
          
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        _handleFirebaseAuthError(e);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<UserModel?> _showAccountSelectionDialog(List<UserModel> accounts) {
    return showDialog<UserModel>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.account_circle, color: Theme.of(context).primaryColor),
              SizedBox(width: 10),
              Text(S.of(context).selectAccount),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: accounts.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final account = accounts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: account.role == UserRole.doctor ? Colors.blue : Colors.teal,
                    child: Icon(
                      account.role == UserRole.doctor ? Icons.medical_services : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    '${account.firstName} ${account.lastName}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.role == UserRole.doctor 
                          ? '${account.doctorTitle} (${account.specialization})' 
                          : account.accountType ?? 'Standard'),
                      if (account.hospitalId != null)
                        FutureBuilder<HospitalModel?>(
                          future: HospitalService(context).getHospitalById(account.hospitalId!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Text('Loading hospital...');
                            }
                            final hospital = snapshot.data;
                            return Text(
                              hospital?.name ?? S.of(context).unknownHospital,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            );
                          },
                        ),
                    ],
                  ),
                  onTap: () => Navigator.of(context).pop(account),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(S.of(context).cancel),
            ),
          ],
        );
      },
    );
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
            child: Text(S.of(context).sendButton),
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

  void _handleFirebaseAuthError(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'user-not-found':
        errorMessage = S.of(context).userNotFound;
        break;
      case 'wrong-password':
        errorMessage = S.of(context).wrongPassword;
        break;
      case 'invalid-email':
        errorMessage = S.of(context).invalidEmail;
        break;
      default:
        errorMessage = e.message ?? S.of(context).basicErrorMessage;
    }
    _showError(errorMessage);
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
                    onPressed: _handleLogin,
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