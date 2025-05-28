class QuizQuestion {
  final String id; // optional, for Firestore document id
  final Map<String, dynamic> marathi;
  final Map<String, dynamic> english;
  final Map<String, dynamic> hindi;

  QuizQuestion({
    required this.id,
    required this.marathi,
    required this.english,
    required this.hindi,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map, String id) {
    return QuizQuestion(
      id: id,
      marathi: Map<String, dynamic>.from(map['marathi']),
      english: Map<String, dynamic>.from(map['english']),
      hindi: Map<String, dynamic>.from(map['hindi']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'marathi': marathi,
      'english': english,
      'hindi': hindi,
    };
  }
}
