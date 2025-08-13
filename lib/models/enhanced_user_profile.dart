import 'package:cloud_firestore/cloud_firestore.dart';

/// Enhanced user profile with admin capabilities
class UserProfile {
  final String? id;
  final String name;
  final String email;
  final String mobile;
  final Set<String> selectedTopics;
  final String preferredLanguage;
  final DateTime createdOn;
  final DateTime? updatedOn;
  final int? points;
  final int? streak;
  final String? subscriptionPlan;
  final UserRole userRole;
  final String? gender;
  final String? institutionId; // For linking to educational institution
  final List<String> adminClassrooms; // Classrooms this user administers
  final List<String> studentClassrooms; // Classrooms this user is a student in
  final UserStatus status;
  final Map<String, dynamic>? preferences;

  UserProfile({
    this.id,
    required this.name,
    required this.email,
    required this.selectedTopics,
    required this.preferredLanguage,
    required this.mobile,
    required this.createdOn,
    this.points,
    this.streak,
    this.subscriptionPlan,
    this.updatedOn,
    this.userRole = UserRole.student,
    this.gender,
    this.institutionId,
    this.adminClassrooms = const [],
    this.studentClassrooms = const [],
    this.status = UserStatus.active,
    this.preferences,
  });

  /// Check if user is an admin
  bool get isAdmin => userRole == UserRole.admin || userRole == UserRole.superAdmin;

  /// Check if user is a teacher
  bool get isTeacher => userRole == UserRole.teacher;

  /// Check if user can create quizzes
  bool get canCreateQuizzes => isAdmin || isTeacher;

  /// Check if user can manage classrooms
  bool get canManageClassrooms => isAdmin || isTeacher;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'selectedTopics': selectedTopics.toList(),
      'preferredLanguage': preferredLanguage,
      'createdOn': createdOn.toIso8601String(),
      'updatedOn': updatedOn?.toIso8601String(),
      'points': points,
      'streak': streak,
      'userRole': userRole.name,
      'gender': gender,
      'subscriptionPlan': subscriptionPlan,
      'institutionId': institutionId,
      'adminClassrooms': adminClassrooms,
      'studentClassrooms': studentClassrooms,
      'status': status.name,
      'preferences': preferences,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'] ?? '',
      selectedTopics: Set<String>.from(map['selectedTopics'] ?? []),
      preferredLanguage: map['preferredLanguage'] ?? 'English',
      createdOn: map['createdOn'] != null 
          ? DateTime.parse(map['createdOn']) 
          : DateTime.now(),
      updatedOn: map['updatedOn'] != null 
          ? DateTime.parse(map['updatedOn']) 
          : null,
      points: map['points'],
      streak: map['streak'],
      userRole: UserRole.values.firstWhere(
        (role) => role.name == map['userRole'],
        orElse: () => UserRole.student,
      ),
      gender: map['gender'],
      subscriptionPlan: map['subscriptionPlan'],
      institutionId: map['institutionId'],
      adminClassrooms: List<String>.from(map['adminClassrooms'] ?? []),
      studentClassrooms: List<String>.from(map['studentClassrooms'] ?? []),
      status: UserStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => UserStatus.active,
      ),
      preferences: map['preferences'],
    );
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }
    return UserProfile.fromMap({...data, 'id': doc.id});
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    Set<String>? selectedTopics,
    String? preferredLanguage,
    DateTime? createdOn,
    DateTime? updatedOn,
    int? points,
    int? streak,
    String? subscriptionPlan,
    UserRole? userRole,
    String? gender,
    String? institutionId,
    List<String>? adminClassrooms,
    List<String>? studentClassrooms,
    UserStatus? status,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      selectedTopics: selectedTopics ?? this.selectedTopics,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdOn: createdOn ?? this.createdOn,
      updatedOn: updatedOn ?? this.updatedOn,
      points: points ?? this.points,
      streak: streak ?? this.streak,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      userRole: userRole ?? this.userRole,
      gender: gender ?? this.gender,
      institutionId: institutionId ?? this.institutionId,
      adminClassrooms: adminClassrooms ?? this.adminClassrooms,
      studentClassrooms: studentClassrooms ?? this.studentClassrooms,
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  String toString() {
    return 'UserProfile{id: $id, name: $name, email: $email, userRole: $userRole, status: $status}';
  }
}

/// User roles in the system
enum UserRole {
  student,
  teacher,
  admin,
  superAdmin;

  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.admin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }
}

/// User status
enum UserStatus {
  active,
  inactive,
  suspended,
  pending;

  String get displayName {
    switch (this) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.inactive:
        return 'Inactive';
      case UserStatus.suspended:
        return 'Suspended';
      case UserStatus.pending:
        return 'Pending';
    }
  }
}
