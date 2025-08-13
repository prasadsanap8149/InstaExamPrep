import 'package:cloud_firestore/cloud_firestore.dart';

/// Enhanced quiz model with room support
class EnhancedQuiz {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? subject;
  final String? grade;
  final QuizType quizType;
  final QuizMode mode;
  final bool isDownloaded;
  final int difficultyLevel;
  final Duration timeLimit;
  final bool isLive;
  final DateTime createdOn;
  final DateTime? updatedOn;
  final String createdBy;
  final QuizStatus status;
  final String? roomId; // Associated room ID
  final List<String> allowedRooms; // Rooms that can access this quiz
  final QuizSettings settings;
  final DateTime? scheduledStartTime;
  final DateTime? scheduledEndTime;
  final List<String> questionIds;
  final Map<String, dynamic> metadata;

  EnhancedQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.subject,
    this.grade,
    this.quizType = QuizType.practice,
    this.mode = QuizMode.individual,
    this.isDownloaded = false,
    this.difficultyLevel = 1,
    required this.timeLimit,
    this.isLive = false,
    required this.createdOn,
    this.updatedOn,
    required this.createdBy,
    this.status = QuizStatus.draft,
    this.roomId,
    this.allowedRooms = const [],
    required this.settings,
    this.scheduledStartTime,
    this.scheduledEndTime,
    this.questionIds = const [],
    this.metadata = const {},
  });

  /// Check if quiz is active
  bool get isActive => status == QuizStatus.published;

  /// Check if quiz is scheduled
  bool get isScheduled => scheduledStartTime != null;

  /// Check if quiz is currently available
  bool get isAvailable {
    if (!isActive) return false;
    final now = DateTime.now();
    if (scheduledStartTime != null && now.isBefore(scheduledStartTime!)) return false;
    if (scheduledEndTime != null && now.isAfter(scheduledEndTime!)) return false;
    return true;
  }

  /// Check if quiz is room-based
  bool get isRoomBased => roomId != null || allowedRooms.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'subject': subject,
      'grade': grade,
      'quizType': quizType.name,
      'mode': mode.name,
      'isDownloaded': isDownloaded,
      'difficultyLevel': difficultyLevel,
      'timeLimit': timeLimit.inSeconds,
      'isLive': isLive,
      'createdOn': createdOn.toIso8601String(),
      'updatedOn': updatedOn?.toIso8601String(),
      'createdBy': createdBy,
      'status': status.name,
      'roomId': roomId,
      'allowedRooms': allowedRooms,
      'settings': settings.toMap(),
      'scheduledStartTime': scheduledStartTime?.toIso8601String(),
      'scheduledEndTime': scheduledEndTime?.toIso8601String(),
      'questionIds': questionIds,
      'metadata': metadata,
    };
  }

  factory EnhancedQuiz.fromMap(Map<String, dynamic> map) {
    return EnhancedQuiz(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      subject: map['subject'],
      grade: map['grade'],
      quizType: QuizType.values.firstWhere(
        (type) => type.name == map['quizType'],
        orElse: () => QuizType.practice,
      ),
      mode: QuizMode.values.firstWhere(
        (mode) => mode.name == map['mode'],
        orElse: () => QuizMode.individual,
      ),
      isDownloaded: map['isDownloaded'] ?? false,
      difficultyLevel: map['difficultyLevel'] ?? 1,
      timeLimit: Duration(seconds: map['timeLimit'] ?? 3600),
      isLive: map['isLive'] ?? false,
      createdOn: map['createdOn'] != null
          ? DateTime.parse(map['createdOn'])
          : DateTime.now(),
      updatedOn: map['updatedOn'] != null
          ? DateTime.parse(map['updatedOn'])
          : null,
      createdBy: map['createdBy'] ?? '',
      status: QuizStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => QuizStatus.draft,
      ),
      roomId: map['roomId'],
      allowedRooms: List<String>.from(map['allowedRooms'] ?? []),
      settings: QuizSettings.fromMap(map['settings'] ?? {}),
      scheduledStartTime: map['scheduledStartTime'] != null
          ? DateTime.parse(map['scheduledStartTime'])
          : null,
      scheduledEndTime: map['scheduledEndTime'] != null
          ? DateTime.parse(map['scheduledEndTime'])
          : null,
      questionIds: List<String>.from(map['questionIds'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  factory EnhancedQuiz.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }
    return EnhancedQuiz.fromMap({...data, 'id': doc.id});
  }

  EnhancedQuiz copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? subject,
    String? grade,
    QuizType? quizType,
    QuizMode? mode,
    bool? isDownloaded,
    int? difficultyLevel,
    Duration? timeLimit,
    bool? isLive,
    DateTime? createdOn,
    DateTime? updatedOn,
    String? createdBy,
    QuizStatus? status,
    String? roomId,
    List<String>? allowedRooms,
    QuizSettings? settings,
    DateTime? scheduledStartTime,
    DateTime? scheduledEndTime,
    List<String>? questionIds,
    Map<String, dynamic>? metadata,
  }) {
    return EnhancedQuiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      quizType: quizType ?? this.quizType,
      mode: mode ?? this.mode,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      timeLimit: timeLimit ?? this.timeLimit,
      isLive: isLive ?? this.isLive,
      createdOn: createdOn ?? this.createdOn,
      updatedOn: updatedOn ?? this.updatedOn,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      roomId: roomId ?? this.roomId,
      allowedRooms: allowedRooms ?? this.allowedRooms,
      settings: settings ?? this.settings,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
      questionIds: questionIds ?? this.questionIds,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'EnhancedQuiz{id: $id, title: $title, status: $status, roomId: $roomId}';
  }
}

/// Quiz types
enum QuizType {
  practice,
  test,
  assignment,
  exam;

  String get displayName {
    switch (this) {
      case QuizType.practice:
        return 'Practice';
      case QuizType.test:
        return 'Test';
      case QuizType.assignment:
        return 'Assignment';
      case QuizType.exam:
        return 'Exam';
    }
  }
}

/// Quiz modes
enum QuizMode {
  individual,
  collaborative,
  competitive;

  String get displayName {
    switch (this) {
      case QuizMode.individual:
        return 'Individual';
      case QuizMode.collaborative:
        return 'Collaborative';
      case QuizMode.competitive:
        return 'Competitive';
    }
  }
}

/// Quiz status
enum QuizStatus {
  draft,
  published,
  scheduled,
  active,
  completed,
  archived;

  String get displayName {
    switch (this) {
      case QuizStatus.draft:
        return 'Draft';
      case QuizStatus.published:
        return 'Published';
      case QuizStatus.scheduled:
        return 'Scheduled';
      case QuizStatus.active:
        return 'Active';
      case QuizStatus.completed:
        return 'Completed';
      case QuizStatus.archived:
        return 'Archived';
    }
  }
}

/// Quiz settings
class QuizSettings {
  final bool shuffleQuestions;
  final bool shuffleOptions;
  final bool showResults;
  final bool allowRetry;
  final int maxAttempts;
  final bool showCorrectAnswers;
  final bool enableHints;
  final bool enableBookmarks;
  final bool requireFullScreen;
  final bool preventScreenshot;
  final Map<String, dynamic> customSettings;

  QuizSettings({
    this.shuffleQuestions = false,
    this.shuffleOptions = false,
    this.showResults = true,
    this.allowRetry = true,
    this.maxAttempts = 3,
    this.showCorrectAnswers = true,
    this.enableHints = false,
    this.enableBookmarks = true,
    this.requireFullScreen = false,
    this.preventScreenshot = false,
    this.customSettings = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'shuffleQuestions': shuffleQuestions,
      'shuffleOptions': shuffleOptions,
      'showResults': showResults,
      'allowRetry': allowRetry,
      'maxAttempts': maxAttempts,
      'showCorrectAnswers': showCorrectAnswers,
      'enableHints': enableHints,
      'enableBookmarks': enableBookmarks,
      'requireFullScreen': requireFullScreen,
      'preventScreenshot': preventScreenshot,
      'customSettings': customSettings,
    };
  }

  factory QuizSettings.fromMap(Map<String, dynamic> map) {
    return QuizSettings(
      shuffleQuestions: map['shuffleQuestions'] ?? false,
      shuffleOptions: map['shuffleOptions'] ?? false,
      showResults: map['showResults'] ?? true,
      allowRetry: map['allowRetry'] ?? true,
      maxAttempts: map['maxAttempts'] ?? 3,
      showCorrectAnswers: map['showCorrectAnswers'] ?? true,
      enableHints: map['enableHints'] ?? false,
      enableBookmarks: map['enableBookmarks'] ?? true,
      requireFullScreen: map['requireFullScreen'] ?? false,
      preventScreenshot: map['preventScreenshot'] ?? false,
      customSettings: Map<String, dynamic>.from(map['customSettings'] ?? {}),
    );
  }

  QuizSettings copyWith({
    bool? shuffleQuestions,
    bool? shuffleOptions,
    bool? showResults,
    bool? allowRetry,
    int? maxAttempts,
    bool? showCorrectAnswers,
    bool? enableHints,
    bool? enableBookmarks,
    bool? requireFullScreen,
    bool? preventScreenshot,
    Map<String, dynamic>? customSettings,
  }) {
    return QuizSettings(
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      shuffleOptions: shuffleOptions ?? this.shuffleOptions,
      showResults: showResults ?? this.showResults,
      allowRetry: allowRetry ?? this.allowRetry,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      showCorrectAnswers: showCorrectAnswers ?? this.showCorrectAnswers,
      enableHints: enableHints ?? this.enableHints,
      enableBookmarks: enableBookmarks ?? this.enableBookmarks,
      requireFullScreen: requireFullScreen ?? this.requireFullScreen,
      preventScreenshot: preventScreenshot ?? this.preventScreenshot,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}
