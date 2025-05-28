import 'package:smartexamprep/models/question.dart';

class Quiz {
  final String id;
  final String title;
  final List<Question> questions;
  final String categoryId;
  final String quizType;
  final bool isDownloaded;
  final int difficultyLevel;
  final int hour;
  final int minute;
  final bool isLive;
  final DateTime createdOn;
  final DateTime createdBy;

  Quiz({
    required this.id,
    required this.title,
    required this.questions,
    required this.categoryId,
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
    return 'Quiz{id: $id, title: $title, questions: $questions, categoryId: $categoryId, quizType: $quizType, isDownloaded: $isDownloaded, difficultyLevel: $difficultyLevel, hour: $hour, minute: $minute, isLive: $isLive, createdOn: $createdOn, createdBy: $createdBy}';
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] as String,
      title: map['title'] as String,
      questions: (map['questions'] as List<dynamic>)
          .map((e) => Question.fromMap(e as Map<String, dynamic>))
          .toList(),
      categoryId: map['categoryId'] as String,
      quizType: map['quizType'] as String,
      isDownloaded: map['isDownloaded'] as bool,
      difficultyLevel: map['difficultyLevel'] as int,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      isLive: map['isLive'] as bool,
      createdOn: DateTime.parse(map['createdOn'] as String),
      createdBy: DateTime.parse(map['createdBy'] as String),
    );
  }
}