import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a classroom/room for quizzes
class QuizRoom {
  final String id;
  final String name;
  final String description;
  final String createdBy; // Admin/Teacher ID
  final String institutionId;
  final List<String> studentIds;
  final List<String> teacherIds;
  final DateTime createdOn;
  final DateTime? updatedOn;
  final RoomStatus status;
  final String? subject;
  final String? grade;
  final Map<String, dynamic> settings;
  final String? inviteCode;
  final DateTime? inviteCodeExpiry;
  final int maxStudents;
  final List<String> quizIds; // Associated quiz IDs

  QuizRoom({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.institutionId,
    required this.studentIds,
    required this.teacherIds,
    required this.createdOn,
    this.updatedOn,
    this.status = RoomStatus.active,
    this.subject,
    this.grade,
    this.settings = const {},
    this.inviteCode,
    this.inviteCodeExpiry,
    this.maxStudents = 100,
    this.quizIds = const [],
  });

  /// Check if room is active
  bool get isActive => status == RoomStatus.active;

  /// Check if invite code is valid
  bool get hasValidInviteCode {
    if (inviteCode == null) return false;
    if (inviteCodeExpiry == null) return true;
    return DateTime.now().isBefore(inviteCodeExpiry!);
  }

  /// Check if room has space for more students
  bool get hasSpace => studentIds.length < maxStudents;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'institutionId': institutionId,
      'studentIds': studentIds,
      'teacherIds': teacherIds,
      'createdOn': createdOn.toIso8601String(),
      'updatedOn': updatedOn?.toIso8601String(),
      'status': status.name,
      'subject': subject,
      'grade': grade,
      'settings': settings,
      'inviteCode': inviteCode,
      'inviteCodeExpiry': inviteCodeExpiry?.toIso8601String(),
      'maxStudents': maxStudents,
      'quizIds': quizIds,
    };
  }

  factory QuizRoom.fromMap(Map<String, dynamic> map) {
    return QuizRoom(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['createdBy'] ?? '',
      institutionId: map['institutionId'] ?? '',
      studentIds: List<String>.from(map['studentIds'] ?? []),
      teacherIds: List<String>.from(map['teacherIds'] ?? []),
      createdOn: map['createdOn'] != null
          ? DateTime.parse(map['createdOn'])
          : DateTime.now(),
      updatedOn: map['updatedOn'] != null
          ? DateTime.parse(map['updatedOn'])
          : null,
      status: RoomStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => RoomStatus.active,
      ),
      subject: map['subject'],
      grade: map['grade'],
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
      inviteCode: map['inviteCode'],
      inviteCodeExpiry: map['inviteCodeExpiry'] != null
          ? DateTime.parse(map['inviteCodeExpiry'])
          : null,
      maxStudents: map['maxStudents'] ?? 100,
      quizIds: List<String>.from(map['quizIds'] ?? []),
    );
  }

  factory QuizRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }
    return QuizRoom.fromMap({...data, 'id': doc.id});
  }

  QuizRoom copyWith({
    String? id,
    String? name,
    String? description,
    String? createdBy,
    String? institutionId,
    List<String>? studentIds,
    List<String>? teacherIds,
    DateTime? createdOn,
    DateTime? updatedOn,
    RoomStatus? status,
    String? subject,
    String? grade,
    Map<String, dynamic>? settings,
    String? inviteCode,
    DateTime? inviteCodeExpiry,
    int? maxStudents,
    List<String>? quizIds,
  }) {
    return QuizRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      institutionId: institutionId ?? this.institutionId,
      studentIds: studentIds ?? this.studentIds,
      teacherIds: teacherIds ?? this.teacherIds,
      createdOn: createdOn ?? this.createdOn,
      updatedOn: updatedOn ?? this.updatedOn,
      status: status ?? this.status,
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      settings: settings ?? this.settings,
      inviteCode: inviteCode ?? this.inviteCode,
      inviteCodeExpiry: inviteCodeExpiry ?? this.inviteCodeExpiry,
      maxStudents: maxStudents ?? this.maxStudents,
      quizIds: quizIds ?? this.quizIds,
    );
  }

  @override
  String toString() {
    return 'QuizRoom{id: $id, name: $name, createdBy: $createdBy, status: $status}';
  }
}

/// Room status enumeration
enum RoomStatus {
  active,
  inactive,
  archived,
  suspended;

  String get displayName {
    switch (this) {
      case RoomStatus.active:
        return 'Active';
      case RoomStatus.inactive:
        return 'Inactive';
      case RoomStatus.archived:
        return 'Archived';
      case RoomStatus.suspended:
        return 'Suspended';
    }
  }
}
