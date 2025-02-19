import 'role_model.dart';

class UserModel {
  final String? id;
  final UserRole role;
  final String firstName;
  final String lastName;
  final String email;
  final String? accountType;
  final List<String>? linkedAccounts;
  final String? doctorTitle;
  final String? specialization;
  final String? licenseNumber;
  final String? profileImageUrl;
  final String? hospitalId;

  UserModel({
    this.id,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.accountType,
    this.linkedAccounts,
    this.doctorTitle,
    this.specialization,
    this.licenseNumber,
    this.profileImageUrl,
    this.hospitalId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.toString(),
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'accountType': accountType,
      'linkedAccounts': linkedAccounts,
      'doctorTitle': doctorTitle,
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'profileImageUrl': profileImageUrl,
      'hospitalId': hospitalId,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      role: _parseRole(json['role']),
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      accountType: json['accountType'],
      linkedAccounts: List<String>.from(json['linkedAccounts'] ?? []),
      doctorTitle: json['doctorTitle'],
      specialization: json['specialization'],
      licenseNumber: json['licenseNumber'],
      profileImageUrl: json['profileImageUrl'],
      hospitalId: json['hospitalId'],
    );
  }

  static UserRole _parseRole(String? roleStr) {
    if (roleStr == null) return UserRole.patient;
    return UserRole.values.firstWhere(
      (e) => e.toString() == roleStr,
      orElse: () => UserRole.patient,
    );
  }
}
