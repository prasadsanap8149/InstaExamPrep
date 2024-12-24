import 'options.dart';

class QuestionsList {
  String? language;
  String? content;
  List<Options>? options;
  String? explanation;
  String? correctOptionId;

  QuestionsList({
    this.language,
    this.content,
    this.options,
    this.explanation,
    this.correctOptionId,
  });

  QuestionsList.fromJson(Map<String, dynamic> json) {
    language = json['language'];
    content = json['content'];
    if (json['options'] != null) {
      options = <Options>[];
      json['options'].forEach((v) {
        options!.add(Options.fromJson(v));
      });
    }
    explanation = json['explanation'];
    correctOptionId = json['correctOptionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['language'] = language;
    data['content'] = content;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    data['explanation'] = explanation;
    data['correctOptionId'] = correctOptionId;
    return data;
  }

  // Converts a map into a QuestionsList object
  static QuestionsList fromMap(Map<String, dynamic> map) {
    return QuestionsList(
      language: map['language'],
      content: map['content'],
      options: map['options'] != null
          ? (map['options'] as List).map((item) => Options.fromMap(item)).toList()
          : null,
      explanation: map['explanation'],
      correctOptionId: map['correctOptionId'],
    );
  }

  // Converts a QuestionsList object into a map
  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'content': content,
      'options': options?.map((o) => o.toMap()).toList(),
      'explanation': explanation,
      'correctOptionId': correctOptionId,
    };
  }

  @override
  String toString() {
    return 'QuestionsList(language: $language, content: $content, options: $options, explanation: $explanation, correctOptionId: $correctOptionId)';
  }
}
