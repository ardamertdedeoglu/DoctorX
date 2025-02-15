class UserModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profileImageUrl;
  final String? accountType;
  final List<String>? linkedAccounts;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profileImageUrl,
    this.accountType,
    this.linkedAccounts,
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
    };
  }
}
