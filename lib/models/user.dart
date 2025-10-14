class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool biometricEnabled;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.lastLoginAt,
    this.biometricEnabled = false,
  });

  // Convert User to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
      'biometricEnabled': biometricEnabled,
    };
  }

  // Create User from Map
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt'] as int)
          : null,
      biometricEnabled: map['biometricEnabled'] as bool? ?? false,
    );
  }

  // Copy with method for updates
  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? biometricEnabled,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}


