import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'generated/l10n.dart';
import 'models/role_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/hospital_model.dart';
import 'services/hospital_service.dart';

class SignupPage extends StatefulWidget {
  final UserRole? initialRole;
  final String? email;
  final String? firstName;
  final String? lastName;

  const SignupPage({
    super.key,
    this.initialRole,
    this.email,
    this.firstName,
    this.lastName,
  });

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
  bool _isDoctor = false;
  final _hospitalController = TextEditingController();
  final _titleController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseController = TextEditingController();
  String _selectedHospitalId = '';

  @override
  void initState() {
    super.initState();
    _isDoctor = widget.initialRole == UserRole.doctor;
    if (widget.email != null) _emailController.text = widget.email!;
    if (widget.firstName != null) _firstNameController.text = widget.firstName!;
    if (widget.lastName != null) _lastNameController.text = widget.lastName!;
  }

  Widget _buildDoctorFields() {
    if (!_isDoctor) return SizedBox.shrink();

    return Column(
      children: [
        SizedBox(height: 16),
        FutureBuilder<List<HospitalModel>>(
          future: HospitalService(context).getHospitals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            
            final hospitals = snapshot.data ?? [];
            
            return DropdownButtonFormField<String>(
              value: _selectedHospitalId,
              decoration: InputDecoration(
                labelText: S.of(context).hospital,
                border: OutlineInputBorder(),
              ),
              items: hospitals.map((hospital) {
                return DropdownMenuItem(
                  value: hospital.id,
                  child: Text(hospital.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHospitalId = value ?? '';
                });
              },
              validator: (value) => 
                _isDoctor && (value?.isEmpty ?? true) ? S.of(context).requiredField : null,
            );
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: S.of(context).doctorTitle,
            border: OutlineInputBorder(),
            hintText: 'Prof. Dr.',
          ),
          validator: (value) => 
            _isDoctor && (value?.isEmpty ?? true) ? S.of(context).requiredField : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _specializationController,
          decoration: InputDecoration(
            labelText: S.of(context).specialization,
            border: OutlineInputBorder(),
            hintText: S.of(context).specializationHintText,
          ),
          validator: (value) => 
            _isDoctor && (value?.isEmpty ?? true) ? S.of(context).requiredField : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _licenseController,
          decoration: InputDecoration(
            labelText: S.of(context).licenseNumber,
            border: OutlineInputBorder(),
            hintText: S.of(context).licenseNumberHintText,
          ),
          validator: (value) => 
            _isDoctor && (value?.isEmpty ?? true) ? S.of(context).requiredField : null,
        ),
        SizedBox(height: 8),
        Text(
          S.of(context).verifyDocuments,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          final userRole = _isDoctor ? UserRole.doctor : UserRole.patient;

          final user = UserModel(
            id: userCredential.user?.uid,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            role: userRole,
            accountType: _isDoctor ? 'doctor' : 'normal',
            doctorTitle: _isDoctor ? _titleController.text : null,
            specialization: _isDoctor ? _specializationController.text : null,
            licenseNumber: _isDoctor ? _licenseController.text : null,
            hospitalId: _isDoctor ? _selectedHospitalId : null,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user?.uid)
              .set(user.toJson());

          // Save user data to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode(user.toJson()));

          // Navigate based on role
          if (_isDoctor) {
            Navigator.pushReplacementNamed(context, '/doctor_home');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
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
            SwitchListTile(
              title: Text(S.of(context).iAmDoctor),
              value: _isDoctor,
              onChanged: (value) => setState(() => _isDoctor = value),
            ),
            _buildDoctorFields(),
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