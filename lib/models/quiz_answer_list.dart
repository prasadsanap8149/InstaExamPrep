import 'dart:convert';

import 'options.dart';

class QuizAnswerList {
  String language;
  String content;
  List<Options> options;
  String explanation;
  String questionId;
  bool isCorrect;
  String selectedOption;

  QuizAnswerList({
    required this.language,
    required this.content,
    required this.options,
    required this.explanation,
    required this.questionId,
    required this.isCorrect,
    required this.selectedOption,
  });

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'content': content,
      'options': options.map((option) => option.toMap()).toList(),
      'explanation': explanation,
      'questionId': questionId,
      'isCorrect': isCorrect,
      'selectedOption': selectedOption,
    };
  }

  factory QuizAnswerList.fromMap(Map<String, dynamic> map) {
    return QuizAnswerList(
      language: map['language'],
      content: map['content'],
      options: List<Options>.from(
          map['options']?.map((x) => Options.fromMap(x)) ?? []),
      explanation: map['explanation'],
      questionId: map['questionId'],
      isCorrect: map['isCorrect'],
      selectedOption: map['selectedOption'],
    );
  }

  String toJson() => json.encode(toMap());

  factory QuizAnswerList.fromJson(String source) =>
      QuizAnswerList.fromMap(json.decode(source));

  @override
  String toString() {
    return 'QuizAnswerList(language: $language, content: $content, options: $options, explanation: $explanation, questionId: $questionId, isCorrect: $isCorrect, selectedOption:$selectedOption)';
  }
}
