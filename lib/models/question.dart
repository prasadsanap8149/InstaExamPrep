import 'package:smartexamprep/models/answer_option.dart';

class Question {
  final String id;
  final String content;
  final List<AnswerOption> options;
  final String explanation;
  final String correctOptionId;
  final int difficultyLevel;

  Question({
    required this.id,
    required this.content,
    required this.options,
    required this.explanation,
    required this.correctOptionId,
    this.difficultyLevel = 1,
  });

  @override
  String toString() {
    return 'Question{id: $id, content: $content, options: $options, explanation: $explanation, correctOptionId: $correctOptionId, difficultyLevel: $difficultyLevel}';
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as String,
      content: map['content'] as String,
      options: (map['options'] as List<dynamic>)
          .map((e) => AnswerOption.fromMap(e as Map<String, dynamic>))
          .toList(),
      explanation: map['explanation'] as String,
      correctOptionId: map['correctOptionId'] as String,
      difficultyLevel: map['difficultyLevel'] as int,
    );
  }
}