import 'role_model.dart';

class UserModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final UserRole role;
  final String? accountType;
  final List<String>? linkedAccounts;
  final String? profileImageUrl;
  final DoctorDetails? doctorDetails;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.accountType,
    this.linkedAccounts,
    this.profileImageUrl,
    this.doctorDetails,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: _parseRole(json['role']),
      accountType: json['accountType'],
      linkedAccounts: json['linkedAccounts'] != null
          ? List<String>.from(json['linkedAccounts'])
          : null,
      profileImageUrl: json['profileImageUrl'],
      doctorDetails: json['doctorDetails'] != null
          ? DoctorDetails.fromJson(json['doctorDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'role': role.toString().split('.').last,
    'accountType': accountType,
    'linkedAccounts': linkedAccounts,
    'profileImageUrl': profileImageUrl,
    'doctorDetails': doctorDetails?.toJson(),
  };

  static UserRole _parseRole(String? roleStr) {
    if (roleStr == 'doctor') return UserRole.doctor;
    return UserRole.patient;
  }
}
