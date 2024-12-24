class Quiz {
  final String id;
  final String title;
  final String category;
  final String quizType;
  final bool isDownloaded;
  final int difficultyLevel;
  final String quizDescription;
  final int hour;
  final int minute;
  final bool isLive;
  final DateTime createdOn;
  final String createdBy;

  Quiz({
    required this.id,
    required this.title,
    required this.quizDescription,
    required this.category,
    required this.quizType,
    this.isDownloaded = false,
    this.difficultyLevel = 1,
    required this.hour,
    required this.minute,
    this.isLive = false,
    required this.createdOn,
    required this.createdBy,
  });

  @override
  String toString() {
    return 'Quiz{id: $id, title: $title, quizDescription: $quizDescription, category: $category, quizType: $quizType, isDownloaded: $isDownloaded, difficultyLevel: $difficultyLevel, hour: $hour, minute: $minute, isLive: $isLive, createdOn: $createdOn, createdBy: $createdBy}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'quizDescription': quizDescription,
      'category': category,
      'quizType': quizType,
      'isDownloaded': isDownloaded,
      'difficultyLevel': difficultyLevel,
      'hour': hour,
      'minute': minute,
      'isLive': isLive,
      'createdOn': createdOn.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] as String,
      title: map['title'] as String,
      quizDescription: map['quizDescription'] as String,
      category: map['category'] as String,
      quizType: map['quizType'] as String,
      isDownloaded: map['isDownloaded'] as bool? ?? false,
      difficultyLevel: map['difficultyLevel'] as int? ?? 1,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      isLive: map['isLive'] as bool? ?? false,
      createdOn: DateTime.parse(map['createdOn'] as String),
      createdBy: map['createdBy'] as String,
    );
  }
}
