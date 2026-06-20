class UserModel {
  final int? id;
  final String fullName;
  final String username;
  final String email;
  final String passwordHash;
  final DateTime createdAt;
  final String? profileImagePath;

  UserModel({
    this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    this.profileImagePath,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      fullName: map['fullName'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      profileImagePath: map['profileImagePath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
      'profileImagePath': profileImagePath,
    };
  }

  UserModel copyWith({
    int? id,
    String? fullName,
    String? username,
    String? email,
    String? passwordHash,
    DateTime? createdAt,
    String? profileImagePath,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  /// Inisial untuk avatar (ambil 1-2 huruf pertama dari fullName)
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
}
