import 'dart:convert';

class Options {
  String option;
  bool isCorrect;

  Options({required this.option, required this.isCorrect});

  // Factory method to create an Options object from a map (used for fromJson)
  factory Options.fromMap(Map<String, dynamic> map) {
    return Options(
      option: map['option'],
      isCorrect: map['isCorrect'],
    );
  }

  // Convert Options object to map (used for toMap)
  Map<String, dynamic> toMap() {
    return {
      'option': option,
      'isCorrect': isCorrect,
    };
  }

  // Convert Options object to JSON string
  String toJson() {
    final jsonMap = toMap();
    return jsonEncode(jsonMap); // Convert map to JSON string
  }

  // Create Options object from JSON string
  factory Options.fromJson(String jsonString) {
    final jsonMap = jsonDecode(jsonString); // Convert JSON string to map
    return Options.fromMap(jsonMap);
  }
}
