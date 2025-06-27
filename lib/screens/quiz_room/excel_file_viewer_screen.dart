import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:random_string/random_string.dart';
import 'package:smartexamprep/models/question.dart';

import '../../database/firebase_service.dart';
import '../../helper/app_colors.dart';
import '../../helper/helper_functions.dart';
import '../../models/options.dart';
import '../../models/question_list.dart';

class ExcelQuestionViewer extends StatefulWidget {
  final String userId;
  final String quizId;

  const ExcelQuestionViewer(
      {super.key, required this.userId, required this.quizId});

  @override
  State<ExcelQuestionViewer> createState() => _ExcelQuestionViewerState();
}

class _ExcelQuestionViewerState extends State<ExcelQuestionViewer> {
  List<Map<String, dynamic>> questions = [];

  Future<void> pickAndParseExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      final sheet = excel.tables[excel.tables.keys.first]!;
      final rows = sheet.rows;

      // Get header map: column name to index
      final headerRow = rows.first;
      final headerMap = <String, int>{};
      for (int i = 0; i < headerRow.length; i++) {
        final cellValue = headerRow[i]?.value?.toString().trim();
        if (cellValue != null && cellValue.isNotEmpty) {
          headerMap[cellValue] = i;
        }
      }

      List<Map<String, dynamic>> parsedQuestions = [];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];

        // Get image link safely using header
        final imageLink = (() {
          final imageColIndex = headerMap["IMAGE LINK"];
          if (imageColIndex != null && imageColIndex < row.length) {
            return row[imageColIndex]?.value?.toString().trim() ?? '';
          }
          return '';
        })();

        // Get passages safely using header
        final marathiPassage = (() {
          final marathiPassageColIndex = headerMap["MARATHI PASSAGE"];
          if (marathiPassageColIndex != null &&
              marathiPassageColIndex < row.length) {
            return row[marathiPassageColIndex]?.value?.toString().trim() ?? '';
          }
          return '';
        })();

        final englishPassage = (() {
          final englishPassageColIndex = headerMap["ENGLISH PASSAGE"];
          if (englishPassageColIndex != null &&
              englishPassageColIndex < row.length) {
            return row[englishPassageColIndex]?.value?.toString().trim() ?? '';
          }
          return '';
        })();

        final hindiPassage = (() {
          final hindiPassageColIndex = headerMap["HINDI PASSAGE"];
          if (hindiPassageColIndex != null &&
              hindiPassageColIndex < row.length) {
            return row[hindiPassageColIndex]?.value?.toString().trim() ?? '';
          }
          return '';
        })();

        Map<String, dynamic> question = {
          "id": randomAlphaNumeric(10),
          "difficultyLevel": 1,
          "type": "Multiple Choice",
          "questionsList": []
        };

        List<String> languages = ["Marathi", "English", "Hindi"];
        int languageOffset = 1;

        for (int langIndex = 0; langIndex < 3; langIndex++) {
          final content = row.length > languageOffset
              ? row[languageOffset]?.value?.toString() ?? ''
              : '';
          final option1 = row.length > languageOffset + 1
              ? row[languageOffset + 1]?.value?.toString() ?? ''
              : '';
          final option2 = row.length > languageOffset + 2
              ? row[languageOffset + 2]?.value?.toString() ?? ''
              : '';
          final option3 = row.length > languageOffset + 3
              ? row[languageOffset + 3]?.value?.toString() ?? ''
              : '';
          final option4 = row.length > languageOffset + 4
              ? row[languageOffset + 4]?.value?.toString() ?? ''
              : '';
          final answerIndex = int.tryParse(row.length > languageOffset + 5
                  ? row[languageOffset + 5]?.value?.toString() ?? '0'
                  : '0') ??
              0;
          final explanation = row.length > languageOffset + 6
              ? row[languageOffset + 6]?.value?.toString() ?? ''
              : '';

          bool hasContent = content.trim().isNotEmpty;
          bool hasOptions =
              option1.trim().isNotEmpty || option2.trim().isNotEmpty;

          if (!hasContent && !hasOptions) {
            languageOffset += 7;
            continue;
          }

          List<Map<String, dynamic>> options = [];

          if (option1.isNotEmpty) {
            options.add({"option": option1, "isCorrect": answerIndex == 1});
          }
          if (option2.isNotEmpty) {
            options.add({"option": option2, "isCorrect": answerIndex == 2});
          }
          if (option3.isNotEmpty) {
            options.add({"option": option3, "isCorrect": answerIndex == 3});
          }
          if (option4.isNotEmpty) {
            options.add({"option": option4, "isCorrect": answerIndex == 4});
          }

          if (options.length == 2) {
            question["type"] = "True/False | Yes/No";
          }

          final questionItem = {
            "language": languages[langIndex],
            "content": content,
            "passage": langIndex == 0
                ? marathiPassage
                : langIndex == 1
                    ? englishPassage
                    : hindiPassage,
            "options": options,
            "explanation": explanation,
            "imageUrl": imageLink,
            "userId": "static-or-dynamic-user-id"
          };

          if (imageLink.isNotEmpty) {
            questionItem["imageUrl"] = imageLink;
          }

          question["questionsList"].add(questionItem);
          languageOffset += 7;
        }

        parsedQuestions.add(question);
      }

      setState(() {
        questions = parsedQuestions;
        debugPrint("Question::$questions");
      });
    }
  }

  void saveQuestion() async {
    final confirm = await HelperFunctions.showCustomDialog(context,
        'Confirm Save', 'Are you sure you want to save the question(s)?');
    debugPrint('Are you sure you want $confirm');
    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      debugPrint('Question List ::${questions.toString()}');
      var finalQuestionList = convertToQuestionsModel(questions, widget.userId);

      await firebaseService.saveOrUpdateQuestions(
        finalQuestionList,
        widget.quizId,
      );

      Navigator.of(context).pop(); // Close the loading spinner
      Navigator.of(context).pop(); // Pop the current screen

      HelperFunctions.showSnackBarMessage(
        context: context,
        message: 'Questions saved successfully!',
        color: Colors.green,
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the spinner
      HelperFunctions.showSnackBarMessage(
        context: context,
        message: 'Error saving questions. Please try again.',
        color: Colors.red,
      );
    }
  }

  List<Questions> convertToQuestionsModel(
      List<Map<String, dynamic>> questionsJsonList, String userId) {
    return questionsJsonList.map((q) {
      List<QuestionsList> qList =
          (q['questionsList'] as List).map<QuestionsList>((ql) {
        List<Options> options = (ql['options'] as List).map<Options>((opt) {
          return Options(
            option: opt['option'] ?? '',
            isCorrect: opt['isCorrect'] ?? false,
          );
        }).toList();

        return QuestionsList(
          language: ql['language'],
          content: ql['content'],
          explanation: ql['explanation'],
          imageUrl: ql['imageUrl'],
          options: options,
          userId: userId,
        );
      }).toList();

      return Questions(
        id: q['id'], // or use randomAlphaNumeric(10) if null
        difficultyLevel: 1,
        type: q['type'],
        questionsList: qList,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel Questions'),
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.accent,
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Column(
        children: [
          questions.isEmpty
              ? const Text('')
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: pickAndParseExcel,
                        icon: const Icon(
                          Icons.file_open,
                          size: 20,
                          color: AppColors.fabIconColor,
                        ),
                        label: const Text(
                          "Pick Again",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.buttonText,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: AppColors.buttonBackground,
                          elevation: 3,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: saveQuestion,
                        icon: const Icon(
                          Icons.save,
                          size: 20,
                          color: AppColors.fabIconColor,
                        ),
                        label: const Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.buttonText,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: AppColors.buttonBackground,
                          elevation: 3,
                        ),
                      ),
                    ],
                  ),
                ),
          Expanded(
            child: questions.isEmpty
                ? Center(
                    child: ElevatedButton.icon(
                      onPressed: pickAndParseExcel,
                      icon: const Icon(
                        Icons.file_open,
                        size: 18,
                        color: AppColors.fabIconColor,
                      ),
                      label: const Text(
                        "Pick Excel File",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.buttonText,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: AppColors.buttonBackground,
                        elevation: 4,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final q = questions[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "QID: ${q['id']}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.indigo),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      q['type'],
                                      style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...q['questionsList'].map<Widget>((ql) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Language Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      margin: const EdgeInsets.only(bottom: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        ql['language'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.deepPurple),
                                      ),
                                    ),
                                    // Question Content
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.help_outline,
                                            size: 18, color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            ql['content'],
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Options
                                    ...ql['options'].map<Widget>((opt) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 2),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: opt['isCorrect']
                                              ? Colors.green.shade50
                                              : Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              opt['isCorrect']
                                                  ? Icons.check_circle_rounded
                                                  : Icons
                                                      .radio_button_unchecked,
                                              color: opt['isCorrect']
                                                  ? Colors.green
                                                  : Colors.grey,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                opt['option'],
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    const SizedBox(height: 6),
                                    // Explanation
                                    if (ql['explanation']
                                        .toString()
                                        .trim()
                                        .isNotEmpty)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.lightbulb_outline,
                                              color: Colors.amber, size: 18),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              ql['explanation'],
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Colors.grey.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (ql['imageUrl']
                                        .toString()
                                        .trim()
                                        .isNotEmpty)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.link,
                                              color: Colors.blue, size: 18),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              ql['imageUrl'],
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Colors.red.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 12),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
