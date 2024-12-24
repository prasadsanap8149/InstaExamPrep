import 'package:smartexamprep/models/question_list.dart';

class Questions {
  String? id;
  int? difficultyLevel;
  String? type;
  List<QuestionsList>? questionsList;

  Questions({this.id, this.difficultyLevel, this.type, this.questionsList});

  Questions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    difficultyLevel = json['difficultyLevel'];
    type = json['type'];
    if (json['questionsList'] != null) {
      questionsList = <QuestionsList>[];
      json['questionsList'].forEach((v) {
        questionsList!.add(QuestionsList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['difficultyLevel'] = difficultyLevel;
    data['type'] = type;
    if (questionsList != null) {
      data['questionsList'] = questionsList!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  // Converts a map into a Questions object
  static Questions fromMap(Map<String, dynamic> map) {
    return Questions(
      id: map['id'],
      difficultyLevel: map['difficultyLevel'],
      type: map['type'],
      questionsList: map['questionsList'] != null
          ? (map['questionsList'] as List)
          .map((item) => QuestionsList.fromMap(item))
          .toList()
          : null,
    );
  }

  // Converts a Questions object into a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'difficultyLevel': difficultyLevel,
      'type': type,
      'questionsList': questionsList?.map((q) => q.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'Questions(id: $id, difficultyLevel: $difficultyLevel, type: $type, questionsList: $questionsList)';
  }
}
