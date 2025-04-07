import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:random_string/random_string.dart';
import 'package:smartexamprep/database/firebase_service.dart';
import 'package:smartexamprep/models/quiz.dart';
import 'package:smartexamprep/screens/question_form.dart';

import '../helper/constants.dart';
import '../helper/helper_functions.dart';
import '../widgets/custom_button.dart';

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
    } else if (quizCategory == null) {
      HelperFunctions.showSnackBarMessage(
          context: context, message: "Select category", color: Colors.red);
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
            category: quizCategory!.trim(),
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
                              quizId:quizId
                              ) //DynamicQuestionForm(userId: widget.userId, quiz: quiz),
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
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _createQuizFormKey,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Constants.isMobileDevice
                    //     ? const GetBannerAd()
                    //     : const Text(""),
                    Column(
                      children: [
                        Text(
                          "Create ${widget.topic} Quiz"
                              ,
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        SizedBox(
                          height: 300,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Hours',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 1.0),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: DropdownButton<int>(
                                            hint: const Text(' Hour'),
                                            underline: const SizedBox(),
                                            value: quizHour,
                                            items: hourOptions.map((int hour) {
                                              return DropdownMenuItem<int>(
                                                value: hour,
                                                child: Text(hour.toString()),
                                              );
                                            }).toList(),
                                            onChanged: (int? newValue) {
                                              setState(() {
                                                quizHour = newValue!;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Minutes',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 1.0),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: DropdownButton<int>(
                                            hint: const Text('Minutes'),
                                            underline: const SizedBox(),
                                            value: quizMinute,
                                            items:
                                                minuteOptions.map((int hour) {
                                              return DropdownMenuItem<int>(
                                                value: hour,
                                                child: Text(hour.toString()),
                                              );
                                            }).toList(),
                                            onChanged: (int? newValue) {
                                              setState(() {
                                                quizMinute = newValue!;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Category',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 1.0),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: DropdownButton<String>(
                                            hint: const Text('Category'),
                                            value: widget.topic,
                                            underline: const SizedBox(),
                                            // Removes default underline
                                            items: Constants.topicNames
                                                .map((String topic) {
                                              return DropdownMenuItem<String>(
                                                value: topic,
                                                child: Text(topic.toString()),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                quizCategory = newValue!;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Type',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 1.0),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: DropdownButton<String>(
                                            hint: const Text('Type'),
                                            underline: const SizedBox(),
                                            value: quizType,
                                            items: Constants.quizType
                                                .map((String topic) {
                                              return DropdownMenuItem<String>(
                                                value: topic,
                                                child: Text(topic.toString()),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                quizType = newValue!;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Quiz Title",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                TextFormField(
                                  controller: quizTitleController,
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: const InputDecoration(
                                    labelText: 'Title',
                                    hintText: 'Enter quiz title.',
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 2.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 1.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'This field cannot be empty';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "Quiz Description",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                TextFormField(
                                  controller: quizDescriptionController,
                                  maxLines: 5,
                                  // Adjust as needed
                                  minLines: 3,
                                  // Minimum height of the text area
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                    hintText: 'Enter quiz description.',
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 2.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 1.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Description cannot be empty';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            submitQuizForm();
                          },
                          child: customButton(
                            btnLabel: "Create",
                            context: context,
                            btnWidth:
                                MediaQuery.of(context).size.width * 0.3855,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: customButton(
                            btnLabel: "Cancel",
                            context: context,
                            btnColor: Colors.blueGrey,
                            btnWidth:
                                MediaQuery.of(context).size.width * 0.3855,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
