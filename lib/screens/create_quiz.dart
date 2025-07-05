import 'dart:io';

import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:smartexamprep/database/firebase_service.dart';
import 'package:smartexamprep/models/quiz.dart';
import 'package:smartexamprep/screens/question_form.dart';

import '../ad_service/widgets/banner_ad.dart';
import '../helper/app_colors.dart';
import '../helper/constants.dart';
import '../helper/helper_functions.dart';

class CreateQuiz extends StatefulWidget {
  final String userId;
  final String topic;

  const CreateQuiz({super.key, required this.userId, required this.topic});

  @override
  State<CreateQuiz> createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {
  final _createQuizFormKey = GlobalKey<FormState>();
  final TextEditingController quizTitleController = TextEditingController();
  final TextEditingController quizDescriptionController =
      TextEditingController();
  String? quizCategory, quizType;
  late String quizId;
  bool _isLoading = false;
  final List<int> hourOptions = List.generate(6, (index) => index.toInt());
  final List<int> minuteOptions =
      List.generate(12, (index) => (index * 5).toInt());
  int quizHour = 0, quizMinute = 0;

  @override
  void initState() {
    super.initState();
  }

  submitQuizForm() async {
    if ((quizHour == 0 && (quizMinute == 0)) ||
        (quizHour == 0 && (quizMinute == 0))) {
      HelperFunctions.showSnackBarMessage(
          context: context,
          message: 'Please select quiz hour or minute',
          color: Colors.red);
    } else if (quizType == null) {
      HelperFunctions.showSnackBarMessage(
          context: context, message: "Select type", color: Colors.red);
    } else {
      if (_createQuizFormKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        quizId = randomAlphaNumeric(16);
        debugPrint(
            "Data received to save : $quizId : ${quizDescriptionController.text.trim()} : ${quizTitleController.text.trim()} : $quizHour : $quizMinute : $quizCategory : $quizType  : ${widget.userId}");
        Quiz quiz = Quiz(
            id: quizId,
            title: quizTitleController.text.trim(),
            quizDescription: quizDescriptionController.text.trim(),
            category: widget.topic.trim(),
            quizType: quizType!.trim(),
            hour: quizHour,
            minute: quizMinute,
            createdOn: DateTime.timestamp(),
            createdBy: widget.userId);
        await firebaseService
            .addQuizData(quiz.toMap(), quizId)
            .then((value) => {
                  setState(() {
                    _isLoading = true;
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddQuestionsDynamic(
                              userId: widget.userId,
                              quizId:
                                  quizId) //DynamicQuestionForm(userId: widget.userId, quiz: quiz),
                          ),
                    );
                  })
                });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic),
        foregroundColor: AppColors.accent,
        backgroundColor: AppColors.appBarBackground,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _createQuizFormKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (Platform.isAndroid || Platform.isIOS) const GetBannerAd(),
                      const SizedBox(height: 5,),
                      Center(
                        child: Text("Create ${widget.topic} Quiz",
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                      ),
                      const SizedBox(height: 20),

                      // Duration Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: quizHour,
                              decoration: const InputDecoration(
                                labelText: "Hour",
                                border: OutlineInputBorder(),
                              ),
                              items: hourOptions
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text("$e")))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => quizHour = val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: quizMinute,
                              decoration: const InputDecoration(
                                labelText: "Minutes",
                                border: OutlineInputBorder(),
                              ),
                              items: minuteOptions
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text("$e")))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => quizMinute = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Category & Type

                      DropdownButtonFormField<String>(
                        value: quizType,
                        decoration: const InputDecoration(
                          labelText: "Type",
                          border: OutlineInputBorder(),
                        ),
                        items: Constants.quizType
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => quizType = val!),
                      ),
                      const SizedBox(height: 16),

                      // Quiz Title
                      TextFormField(
                        controller: quizTitleController,
                        decoration: const InputDecoration(
                          labelText: "Quiz Title",
                          hintText: "Enter quiz title",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Title cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Quiz Description
                      TextFormField(
                        controller: quizDescriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: "Quiz Description",
                          hintText: "Enter quiz description",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton.icon(
                        onPressed: submitQuizForm,
                        icon: const Icon(Icons.save,
                            color: AppColors.fabIconColor),
                        label: const Text(
                          'Save',
                          style: TextStyle(color: AppColors.buttonText),
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                            backgroundColor: AppColors.fabBackground),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.fabIconColor),
                        label: const Text(
                          'Back',
                          style: TextStyle(color: AppColors.buttonText),
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                            backgroundColor: AppColors.fabBackground),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
