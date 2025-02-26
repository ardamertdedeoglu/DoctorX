import 'package:flutter/material.dart';
import 'main.dart';
import 'generated/l10n.dart';
import 'models/user_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/role_model.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  UserModel? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');
    
    if (userDataStr != null) {
      final userData = UserModel.fromJson(jsonDecode(userDataStr));
      if (userData.role != UserRole.doctor) {
        // Eğer doktor değilse ana sayfaya yönlendir
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }
      
      setState(() {
        _userData = userData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).homePageTitle),
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
                    ? '${S.of(context).welcomeMessage}, Dr. ${_userData!.firstName}!'
                    : S.of(context).welcomeMessage,
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                S.of(context).preparingApp,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
