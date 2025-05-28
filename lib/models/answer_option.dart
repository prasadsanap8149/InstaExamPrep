class AnswerOption {
  final String id;
  final String content;
  final bool isCorrect;

  AnswerOption({
    required this.id,
    required this.content,
    this.isCorrect = false,
  });

  @override
  String toString() {
    return 'AnswerOption{id: $id, content: $content, isCorrect: $isCorrect}';
  }

  factory AnswerOption.fromMap(Map<String, dynamic> map) {
    return AnswerOption(
      id: map['id'] as String,
      content: map['content'] as String,
      isCorrect: map['isCorrect'] as bool,
    );
  }
}