class UserModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? accountType; // 'parent' or 'child'
  final String? parentId; // If this is a child account, stores parent's ID
  final List<String>? linkedAccounts; // Store IDs of linked child accounts
  final String? profileImageUrl;  // Yeni alan ekle
  final bool isDarkMode;  // Yeni alan ekle
  final bool rememberMe; // Yeni alan

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.accountType,
    this.parentId,
    this.linkedAccounts,
    this.profileImageUrl,
    this.isDarkMode = false,  // Varsayılan değer
    this.rememberMe = false, // Varsayılan değer
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'accountType': accountType,
        'parentId': parentId,
        'linkedAccounts': linkedAccounts,
        'profileImageUrl': profileImageUrl,
        'isDarkMode': isDarkMode,  // Yeni alanı ekle
        'rememberMe': rememberMe, // JSON'a ekle
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        accountType: json['accountType'],
        parentId: json['parentId'],
        linkedAccounts: json['linkedAccounts'] != null
            ? List<String>.from(json['linkedAccounts'])
            : null,
        profileImageUrl: json['profileImageUrl'],
        isDarkMode: json['isDarkMode'] ?? false,  // Yeni alanı oku
        rememberMe: json['rememberMe'] ?? false, // JSON'dan oku
      );
}
