class AuthResponse {
  final String? userId;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
  final DateTime? creationTime;
  final DateTime? lastSignInTime;

  AuthResponse({
     this.userId,
     this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.creationTime,
    this.lastSignInTime,
  });

  factory AuthResponse.fromMap(Map<String, dynamic> map) {
    return AuthResponse(
      userId: map['uid'] as String?,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoURL'] as String?,
      emailVerified: map['emailVerified'] as bool? ?? false,
      creationTime: map['metadata'] != null ? DateTime.tryParse(map['metadata']['creationTime'] as String) : null,
      lastSignInTime: map['metadata'] != null ? DateTime.tryParse(map['metadata']['lastSignInTime'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': userId,
      'email': email,
      'displayName': displayName,
      'photoURL': photoUrl,
      'emailVerified': emailVerified,
      'creationTime': creationTime?.toIso8601String(),
      'lastSignInTime': lastSignInTime?.toIso8601String(),
    };
  }
}
