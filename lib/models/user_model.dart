import 'role_model.dart';

class UserModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profileImageUrl;
  final String? accountType;
  final List<String>? linkedAccounts;
  final UserRole role;
  final DoctorDetails? doctorDetails;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profileImageUrl,
    this.accountType,
    this.linkedAccounts,
    required this.role,
    this.doctorDetails,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      accountType: json['accountType'],
      linkedAccounts: List<String>.from(json['linkedAccounts'] ?? []),
      role: UserRole.values.firstWhere(
        (e) => e.toString() == json['role'],
        orElse: () => UserRole.patient,
      ),
      doctorDetails: json['doctorDetails'] != null 
        ? DoctorDetails.fromJson(json['doctorDetails']) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'accountType': accountType,
      'linkedAccounts': linkedAccounts,
      'role': role.toString(),
      'doctorDetails': doctorDetails?.toJson(),
    };
  }
}
