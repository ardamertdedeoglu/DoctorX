import 'role_model.dart';

class UserModel {
  final String? id;
  final UserRole role;
  final String firstName;
  final String lastName;
  final String email;
  final String? accountType;
  final List<String>? linkedAccounts; // Bağlı hesapların ID'leri
  final String? profileImageUrl;
  final String? doctorTitle;
  final String? specialization;
  final String? licenseNumber;
  final String? originalAccountId; // Ana hesabın ID'si (doktor hesabı için)
  final String? hospitalId; // Added hospitalId

  UserModel({
    this.id,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.accountType,
    this.linkedAccounts,
    this.profileImageUrl,
    this.doctorTitle,
    this.specialization,
    this.licenseNumber,
    this.originalAccountId,
    this.hospitalId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role.toString(),
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'accountType': accountType,
    'linkedAccounts': linkedAccounts,
    'profileImageUrl': profileImageUrl,
    'doctorTitle': doctorTitle,
    'specialization': specialization,
    'licenseNumber': licenseNumber,
    'originalAccountId': originalAccountId,
    'hospitalId': hospitalId,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    role: _parseRole(json['role']),
    firstName: json['firstName'],
    lastName: json['lastName'],
    email: json['email'],
    accountType: json['accountType'],
    linkedAccounts: json['linkedAccounts'] != null 
        ? List<String>.from(json['linkedAccounts'])
        : null,
    profileImageUrl: json['profileImageUrl'],
    doctorTitle: json['doctorTitle'],
    specialization: json['specialization'],
    licenseNumber: json['licenseNumber'],
    originalAccountId: json['originalAccountId'],
    hospitalId: json['hospitalId'],
  );

  static UserRole _parseRole(String? role) {
    if (role == null) return UserRole.patient;
    return UserRole.values.firstWhere(
      (e) => e.toString() == role,
      orElse: () => UserRole.patient,
    );
  }

  UserModel copyWith({
    String? id,
    UserRole? role,
    String? firstName,
    String? lastName,
    String? email,
    String? accountType,
    List<String>? linkedAccounts,
    String? profileImageUrl,
    String? doctorTitle,
    String? specialization,
    String? licenseNumber,
    String? originalAccountId,
    String? hospitalId,
  }) {
    return UserModel(
      id: id ?? this.id,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      accountType: accountType ?? this.accountType,
      linkedAccounts: linkedAccounts ?? this.linkedAccounts,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      doctorTitle: doctorTitle ?? this.doctorTitle,
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      originalAccountId: originalAccountId ?? this.originalAccountId,
      hospitalId: hospitalId ?? this.hospitalId,
    );
  }
}
