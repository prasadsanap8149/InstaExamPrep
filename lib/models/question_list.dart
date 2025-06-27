import 'options.dart';

class QuestionsList {
  String? language;
  String? content;
  String? passage;
  List<Options>? options;
  String? explanation;
  String? userId;
  String? imageUrl;

  QuestionsList(
      {this.language,
      this.content,
      this.passage,
      this.options,
      this.explanation,
      this.imageUrl,
      this.userId});

  QuestionsList.fromJson(Map<String, dynamic> json) {
    language = json['language'];
    content = json['content'];
    passage = json['passage'];
    if (json['options'] != null) {
      options = <Options>[];
      json['options'].forEach((v) {
        options!.add(Options.fromJson(v));
      });
    }
    explanation = json['explanation'];
    imageUrl = json['imageUrl'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['language'] = language;
    data['content'] = content;
    data['passage'] = passage;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    data['explanation'] = explanation;
    data['imageUrl'] = imageUrl;
    data['userId'] = userId;
    return data;
  }

  // Converts a map into a QuestionsList object
  static QuestionsList fromMap(Map<String, dynamic> map) {
    return QuestionsList(
      language: map['language'],
      content: map['content'],
      passage: map['passage'],
      options: map['options'] != null
          ? (map['options'] as List)
              .map((item) => Options.fromMap(item))
              .toList()
          : null,
      explanation: map['explanation'],
      imageUrl: map['imageUrl'],
      userId: map['userId'],
    );
  }

  // Converts a QuestionsList object into a map
  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'content': content,
      'passage': passage,
      'options': options?.map((o) => o.toMap()).toList(),
      'explanation': explanation,
      'imageUrl': imageUrl,
      'userId': userId,
    };
  }

  @override
  String toString() {
    return 'QuestionsList(language: $language, content: $content, passage: $passage, options: $options, explanation: $explanation, imageUrl: $imageUrl, userId: $userId';
  }
}
