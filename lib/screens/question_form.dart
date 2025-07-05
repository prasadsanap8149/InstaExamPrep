import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:random_string/random_string.dart';
import 'package:smartexamprep/database/firebase_service.dart';
import 'package:smartexamprep/helper/app_colors.dart';
import 'package:smartexamprep/helper/helper_functions.dart';
import 'package:smartexamprep/models/question.dart';
import 'package:smartexamprep/models/question_list.dart';
import 'package:smartexamprep/screens/quiz_room/excel_file_viewer_screen.dart';
import 'package:smartexamprep/screens/view_question_list.dart';

import '../ad_service/widgets/banner_ad.dart';
import '../models/options.dart';

class AddQuestionsDynamic extends StatefulWidget {
  final String userId;
  final String quizId;

  const AddQuestionsDynamic(
      {super.key, required this.userId, required this.quizId});

  @override
  State<AddQuestionsDynamic> createState() => _AddQuestionsDynamicState();
}

class _AddQuestionsDynamicState extends State<AddQuestionsDynamic> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedQuestionType;
  final List<String> questionTypes = ['Multiple Choice', 'True/False | Yes/No'];
  Map<String, bool> languageSelection = {
    'English': false,
    'Marathi': false,
    'Hindi': false,
  };
  List<String> selectedLanguage = [];
  List<QuestionsList> localizedQuestions = [];
  List<Questions> finalQuestionList = [];
  Map<String, List<Options>> languageOptions = {};

  void initializeMultipleChoiceOptions(String language) {
    languageOptions[language] = [
      Options(option: '', isCorrect: false),
      Options(option: '', isCorrect: false),
      Options(option: '', isCorrect: false),
      Options(option: '', isCorrect: false),
    ];
  }

  void initializeTrueFalseOptions(String language) {
    languageOptions[language] = [
      Options(option: '', isCorrect: false),
      Options(option: '', isCorrect: false),
    ];
  }

  void addOption(String language) {
    setState(() {
      languageOptions[language]?.add(Options(option: '', isCorrect: false));
    });
  }

  void removeOption(String language, int index) {
    setState(() {
      languageOptions[language]?.removeAt(index);
    });
  }

  Widget buildOptions(String language) {
    return Column(
      children: [
        ...languageOptions[language]!.asMap().entries.map((entry) {
          int index = entry.key;
          Options option = entry.value;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Radio Button for Correct Option
                Column(
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: languageOptions[language]!
                          .indexWhere((opt) => opt.isCorrect),
                      onChanged: (value) {
                        setState(() {
                          for (var opt in languageOptions[language]!) {
                            opt.isCorrect = false;
                          }
                          option.isCorrect = true;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 8.0),
                // Option Content Text Area
                Expanded(
                  child: TextFormField(
                    initialValue: option.option,
                    maxLines: 3,
                    // Allows the text area to span 3 lines
                    minLines: 1,
                    // Minimum height for the text area
                    decoration: InputDecoration(
                      labelText: 'Option ${index + 1}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        option.option = value;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Option cannot be empty'
                        : null,
                  ),
                ),
                const SizedBox(width: 8.0),

                // Delete Button
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeOption(language, index),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => addOption(language),
            icon: const Icon(
              Icons.add_circle,
              size: 18,
              color: AppColors.fabIconColor,
            ),
            label: const Text(
              'Add Option',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shadowColor: Colors.blueAccent,
              elevation: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLanguageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Languages:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Column(
          children: languageSelection.keys.map((lang) {
            return CheckboxListTile(
              title: Text(lang),
              value: languageSelection[lang],
              onChanged: (value) {
                setState(() {
                  languageSelection[lang] = value!;
                  if (value) {
                    selectedLanguage.add(lang);
                    localizedQuestions.add(QuestionsList(language: lang));
                    // Initialize options for the language
                    if (selectedQuestionType == 'Multiple Choice') {
                      initializeMultipleChoiceOptions(lang);
                    } else if (selectedQuestionType == 'True/False | Yes/No') {
                      initializeTrueFalseOptions(lang);
                    }
                  } else {
                    selectedLanguage.remove(lang);
                    localizedQuestions.removeWhere((q) => q.language == lang);
                    languageOptions
                        .remove(lang); // Remove options for the language
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildLocalizedForms() {
    return Column(
      children: selectedLanguage.map((lang) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language: $lang',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 5,
              minLines: 2,
              decoration: InputDecoration(
                labelText: 'Question Content ($lang)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  localizedQuestions
                      .firstWhere((q) => q.language == lang,
                          orElse: () => QuestionsList(language: lang))
                      .content = value;
                });
              },
              validator: (value) => value == null || value.isEmpty
                  ? 'Question content for $lang cannot be empty'
                  : null,
            ),
            const SizedBox(height: 8),
            if (selectedQuestionType == 'Multiple Choice' ||
                selectedQuestionType == 'True/False | Yes/No')
              buildOptions(lang),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 5,
              minLines: 2,
              decoration: InputDecoration(
                labelText: 'Explanation ($lang)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  localizedQuestions
                      .firstWhere((q) => q.language == lang,
                          orElse: () => QuestionsList(language: lang))
                      .explanation = value;
                });
              },
              validator: (value) => value == null || value.isEmpty
                  ? 'Explanation for $lang cannot be empty'
                  : null,
            ),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }

  void saveLocalizedQuestions() {
    if (_formKey.currentState!.validate()) {
      //Check question language selected or not
      if (selectedLanguage.isEmpty) {
        HelperFunctions.showSnackBarMessage(
            context: context,
            message: 'Please select the language',
            color: Colors.redAccent);
        return;
      }
      _formKey.currentState!.save();
      bool flag;
      for (QuestionsList question in localizedQuestions) {
        flag = true;
        for (var e in languageOptions[question.language]!) {
          if (e.isCorrect) {
            flag = false;
          }
        }
        if (flag) {
          HelperFunctions.showSnackBarMessage(
              context: context,
              message: 'Please select at least one correct option',
              color: Colors.redAccent);
          return;
        }

        question.options = languageOptions[question.language]!;

        question.userId = widget.userId;
        // Save the options
        debugPrint('Saving the question ::${question.toString()}');

        // List<Options> optionsForLanguage = languageOptions[question.language]!;
      }
      finalQuestionList.add(Questions(
          id: randomAlphaNumeric(10),
          difficultyLevel: 1,
          type: selectedQuestionType,
          questionsList: localizedQuestions));
      resetAll();
    }
  }

  void resetAll() {
    setState(() {
      languageOptions = {};
      selectedLanguage = [];
      localizedQuestions = [];
      languageOptions = {};
      languageSelection = {
        'English': false,
        'Marathi': false,
        'Hindi': false,
      };
    });
  }

  void viewQuestions() {
    debugPrint('Question List ::${finalQuestionList.toString()}');
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ViewQuestionList(
              quizId: widget.quizId, questionList: finalQuestionList)),
    );
  }

  void saveQuestion() async {
    debugPrint('Question List ::${finalQuestionList.toString()}');
    await firebaseService.saveOrUpdateQuestions(
        finalQuestionList, widget.quizId);
  }

  void fetchQuestion() async {
    // Fetch the questions asynchronously
    final fetchedQuestions =
        await firebaseService.fetchQuestions(widget.quizId);

    // Update the state with the fetched data
    setState(() {
      finalQuestionList = fetchedQuestions;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchQuestion();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions'),
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.accent,
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (Platform.isAndroid || Platform.isIOS) const GetBannerAd(),
              const SizedBox(height: 5,),
              DropdownButtonFormField<String>(
                value: selectedQuestionType,
                items: questionTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedQuestionType = value;
                    // Initialize options for all selected languages
                    for (var lang in selectedLanguage) {
                      if (value == questionTypes[1]) {
                        initializeTrueFalseOptions(lang);
                      } else if (value == questionTypes[0]) {
                        initializeMultipleChoiceOptions(lang);
                      }
                    }
                  });
                },
                decoration: const InputDecoration(labelText: 'Question Type'),
                validator: (value) =>
                    value == null ? 'Please select a question type' : null,
              ),
              buildLanguageSelection(),
              const SizedBox(height: 16),
              buildLocalizedForms(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: saveLocalizedQuestions,
                icon: const Icon(
                  Icons.add,
                  size: 18,
                  color: AppColors.fabIconColor,
                ),
                label: const Text(
                  'Add Question',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.buttonText),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: AppColors.buttonBackground,
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                onPressed: viewQuestions,
                icon: const Icon(
                  Icons.visibility,
                  size: 18,
                  color: AppColors.fabIconColor,
                ),
                label: const Text(
                  'View Questions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.buttonText,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: AppColors.buttonBackground,
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                onPressed: saveQuestion,
                icon: const Icon(
                  Icons.save,
                  size: 18,
                  color: AppColors.fabIconColor,
                ),
                label: const Text(
                  'Save Questions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.buttonText,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: AppColors.buttonBackground,
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Upload Question.",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExcelQuestionViewer(
                userId: widget.userId,
                quizId: widget.quizId,
              ),
            ),
          );
        },
        backgroundColor: AppColors.fabBackground,
        // custom background color
        foregroundColor: AppColors.fabIconColor,
        // custom icon color if needed
        child: const Icon(
          Icons.upload,
          color: AppColors.appBarIcon,
        ),
      ),
    );
  }
}
