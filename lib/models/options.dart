import 'dart:convert';

class Options {
  String option;
  bool isCorrect;

  Options({required this.option, required this.isCorrect});

  // Factory method to create an Options object from a map
  factory Options.fromMap(Map<String, dynamic> map) {
    return Options(
      option: map['option'] as String,
      isCorrect: map['isCorrect'] as bool,
    );
  }

  // Convert Options object to map
  Map<String, dynamic> toMap() {
    return {
      'option': option,
      'isCorrect': isCorrect,
    };
  }

  // Convert Options object to JSON string
  String toJson() => jsonEncode(toMap());

  // Create Options object from JSON string
  factory Options.fromJson(String jsonString) =>
      Options.fromMap(jsonDecode(jsonString));

  // Override toString for better readability
  @override
  String toString() {
    return 'Options(option: $option, isCorrect: $isCorrect)';
  }
}
