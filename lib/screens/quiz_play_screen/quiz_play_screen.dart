import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartexamprep/helper/app_colors.dart';
import 'package:smartexamprep/helper/helper_functions.dart';
import 'package:smartexamprep/models/quiz_answer_list.dart';
import 'package:smartexamprep/screens/quiz_play_screen/report_screen.dart';

import '../../database/firebase_service.dart';
import '../../models/question.dart';
import '../../models/question_list.dart';
import '../../widgets/animated_custom_button.dart';
import '../../widgets/compact_countdown_timer.dart';

class QuizPlayScreen extends StatefulWidget {
  final String quizId;
  final String userId;
  final Duration duration;

  const QuizPlayScreen(
      {super.key,
      required this.quizId,
      required this.userId,
      required this.duration});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> 
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  List<Questions> finalQuestionList = [];
  String selectedLanguage = 'English';
  int currentQuestionIndex = 0;
  Map<String, QuizAnswerList> userAnswers = {};
  bool _timeoutReached = false;
  bool _isLoading = true;
  bool _isDisposed = false;
  late int perQuestionDurationInSeconds;
  Timer? questionTimer;
  Timer? _fetchTimeout;
  int remainingTime = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeQuiz();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _cancelTimers();
    super.dispose();
  }

  void _cancelTimers() {
    questionTimer?.cancel();
    _fetchTimeout?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Pause timer when app goes to background
        questionTimer?.cancel();
        break;
      case AppLifecycleState.resumed:
        // Resume timer when app comes back to foreground
        if (!_isDisposed && mounted && finalQuestionList.isNotEmpty) {
          startQuestionTimer();
        }
        break;
      case AppLifecycleState.detached:
        _cancelTimers();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _initializeQuiz() async {
    try {
      await fetchQuestion();
    } catch (e) {
      if (mounted) {
        HelperFunctions.showSnackBarMessage(
          context: context,
          message: 'Failed to load quiz: $e',
          color: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> fetchQuestion() async {
    if (_isDisposed) return;
    
    try {
      // Set timeout for question fetching
      _fetchTimeout = Timer(const Duration(seconds: 15), () {
        if (mounted && finalQuestionList.isEmpty) {
          setState(() {
            _timeoutReached = true;
            _isLoading = false;
          });
        }
      });

      final fetchedQuestions = await firebaseService.fetchQuestions(widget.quizId);
      
      _fetchTimeout?.cancel();
      
      if (!_isDisposed && mounted) {
        setState(() {
          finalQuestionList = fetchedQuestions;
          _isLoading = false;
          
          if (finalQuestionList.isNotEmpty) {
            perQuestionDurationInSeconds = 
                (widget.duration.inSeconds / finalQuestionList.length).round();
            // Ensure minimum 10 seconds per question
            perQuestionDurationInSeconds = perQuestionDurationInSeconds < 10 
                ? 10 : perQuestionDurationInSeconds;
            startQuestionTimer();
          } else {
            _timeoutReached = true;
          }
        });
      }
    } catch (error) {
      if (!_isDisposed && mounted) {
        setState(() {
          _timeoutReached = true;
          _isLoading = false;
        });
        
        HelperFunctions.showSnackBarMessage(
          context: context,
          message: 'Error loading questions: $error',
          color: Colors.red,
        );
      }
    }
  }

  void startQuestionTimer() {
    if (_isDisposed) return;
    
    questionTimer?.cancel();
    remainingTime = perQuestionDurationInSeconds;

    questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed || !mounted) {
        timer.cancel();
        return;
      }
      
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
        // Auto-move to next question when time expires
        _handleTimeExpiry();
      }
    });
  }

  void _handleTimeExpiry() {
    if (_isDisposed || !mounted) return;
    
    // Save empty answer for current question if no answer selected
    final currentQuestion = finalQuestionList[currentQuestionIndex];
    final questionContent = _getCurrentQuestionContent();
    
    if (questionContent != null && 
        !userAnswers.containsKey(currentQuestion.id)) {
      saveAnswer(false, '', questionContent);
    }
    
    // Move to next question or finish quiz
    if (currentQuestionIndex < finalQuestionList.length - 1) {
      nextQuestion();
    } else {
      submitQuiz();
    }
  }

  QuestionsList? _getCurrentQuestionContent() {
    if (finalQuestionList.isEmpty || 
        currentQuestionIndex >= finalQuestionList.length) {
      return null;
    }
    
    final currentQuestion = finalQuestionList[currentQuestionIndex];
    return currentQuestion.questionsList?.firstWhere(
      (q) => q.language == selectedLanguage,
      orElse: () => currentQuestion.questionsList?.first ?? QuestionsList(),
    );
  }

  void selectLanguage(String language) {
    setState(() {
      selectedLanguage = language;
    });
  }

  void nextQuestion() {
    if (_isDisposed || !mounted) return;
    
    if (currentQuestionIndex < finalQuestionList.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      startQuestionTimer();
    } else {
      HelperFunctions.showSnackBarMessage(
          context: context,
          message: 'This is last question',
          color: Colors.redAccent);
    }
  }

  void previousQuestion() {
    if (_isDisposed || !mounted) return;
    
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
      startQuestionTimer();
    } else {
      HelperFunctions.showSnackBarMessage(
          context: context,
          message: 'This is first question',
          color: Colors.redAccent);
    }
  }

  void saveAnswer(
      bool isCorrect, String selectedOption, QuestionsList questionContent) {
    setState(() {
      userAnswers[finalQuestionList[currentQuestionIndex].id!] = QuizAnswerList(
          language: questionContent.language!,
          content: questionContent.content!,
          options: questionContent.options!,
          explanation: questionContent.explanation!,
          questionId: finalQuestionList[currentQuestionIndex].id!,
          isCorrect: isCorrect,
          selectedOption: selectedOption);
      debugPrint('Saving Answer ::$isCorrect');
      debugPrint(
          'Saving Answer : questionContent::${questionContent.toString()}');
      debugPrint('Saving Answer : quizAnswerList::${userAnswers.toString()}');
    });
  }

  void submitQuiz() {
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportScreen(userAnswers: userAnswers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (finalQuestionList.isEmpty && !_timeoutReached) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Play'),
          backgroundColor: AppColors.appBarBackground,
          foregroundColor: AppColors.accent,
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.exit_to_app_rounded,
                color: AppColors.fabIconColor,
              ),
              color: AppColors.appBarIcon,
              tooltip: "Exit",
              onPressed: () async {
                final bool shouldExit = await HelperFunctions.showCustomDialog(
                      context,
                      "Exit Exam",
                      "Are you sure you want to exit the exam? Your progress may be lost.",
                    ) ??
                    false;

                if (!context.mounted) return;
                if (shouldExit) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (finalQuestionList.isEmpty && _timeoutReached) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Play'),
          backgroundColor: AppColors.appBarBackground,
          foregroundColor: AppColors.accent,
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.exit_to_app_rounded,
                color: AppColors.fabIconColor,
              ),
              color: AppColors.appBarIcon,
              tooltip: "Exit",
              onPressed: () async {
                final bool shouldExit = await HelperFunctions.showCustomDialog(
                      context,
                      "Exit Exam",
                      "Are you sure you want to exit the exam? Your progress may be lost.",
                    ) ??
                    false;

                if (!context.mounted) return;
                if (shouldExit) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        body: const Center(
          child: Center(
            child: Text(
              "No Questions Available.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }
    String getFormattedOption(String optionText, int index) {
      final prefixes = [
        '(1)',
        '(2)',
        '(3)',
        '(4)',
      ];
      if (prefixes.any((prefix) => optionText.trim().startsWith(prefix))) {
        return optionText;
      } else if (index >= 0 && index < prefixes.length) {
        return '${prefixes[index]} $optionText';
      } else {
        // fallback for any index beyond 4
        return '(${index + 1}) $optionText';
      }
    }

    final currentQuestion = finalQuestionList[currentQuestionIndex];
    final questionLanguages =
        currentQuestion.questionsList!.map((q) => q.language).toSet().toList();
    final questionContent = currentQuestion.questionsList?.firstWhere(
      (q) => q.language == selectedLanguage,
      orElse: () {
        // Auto-select first available language if selected one is not found
        if (currentQuestion.questionsList != null &&
            currentQuestion.questionsList!.isNotEmpty) {
          selectedLanguage = currentQuestion.questionsList!.first.language!;
          return currentQuestion.questionsList!.first;
        }
        return QuestionsList(
          language: '',
          content: 'Please select available language.',
          options: [],
          userId: '',
          explanation: '',
        );
      },
    );

    return PopScope(
      canPop: false, // Prevents default pop unless explicitly allowed
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final bool shouldExit = await HelperFunctions.showCustomDialog(
              context,
              "Exit Exam",
              "Are you sure you want to exit the exam? Your progress may be lost.",
            ) ??
            false;

        if (!context.mounted) return;
        if (shouldExit) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exam'),
          centerTitle: true,
          backgroundColor: AppColors.appBarBackground,
          foregroundColor: AppColors.accent,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: CompactCountdownTimer(duration: widget.duration),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app_rounded),
              tooltip: "Exit",
              onPressed: () async {
                final shouldExit = await HelperFunctions.showCustomDialog(
                      context,
                      "Exit Exam",
                      "Are you sure you want to exit the exam?",
                    ) ??
                    false;
                if (shouldExit && context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer,
                                    color: Colors.redAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'Question Timer: $remainingTime sec',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Select Language:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: questionLanguages.map((language) {
                            final isSelected = selectedLanguage == language;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  language!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (_) => selectLanguage(language),
                                selectedColor: Colors.blueAccent,
                                backgroundColor: Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      questionContent?.passage != null
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color:
                                        Colors.grey.shade400), // subtle border
                              ),
                              height: 350, // fixed height for scrollable area
                              child: Scrollbar(
                                thumbVisibility:
                                    true, // always show scrollbar thumb
                                thickness: 4,
                                radius: const Radius.circular(8),
                                child: SingleChildScrollView(
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      questionContent!.passage!,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),

                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${currentQuestionIndex + 1}) ${questionContent!.content!} ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      questionContent.imageUrl != null
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  questionContent.imageUrl!,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const SizedBox(
                                      height: 200,
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox(
                                      height: 200,
                                      child: Center(
                                          child: Text('Image failed to load')),
                                    );
                                  },
                                ),
                              ),
                            )
                          : const Text(''),
                      const SizedBox(height: 20),

                      // Options
                      ...questionContent.options!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;

                        final isSelected = userAnswers[
                                    finalQuestionList[currentQuestionIndex].id!]
                                ?.selectedOption ==
                            option.option;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.green[100] : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => saveAnswer(option.isCorrect,
                                  option.option, questionContent),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 14.0),
                                child: Text(
                                  getFormattedOption(option.option, index),
                                  // <-- Fixed here
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.green[900]
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
              child: Column(
                children: [
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedCustomButton(
                        btnLabel: "Previous",
                        btnColor: AppColors.buttonBackgroundSecondary,
                        onTap: previousQuestion,
                        btnWidth: MediaQuery.of(context).size.width * 0.4,
                      ),
                      AnimatedCustomButton(
                        btnLabel: "Next",
                        btnColor: AppColors.buttonBackgroundSecondary,
                        onTap: nextQuestion,
                        btnWidth: MediaQuery.of(context).size.width * 0.4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Submit button
                  if (userAnswers.length == finalQuestionList.length)
                    Center(
                      child: AnimatedCustomButton(
                        btnLabel: "Submit",
                        btnColor: AppColors.accent,
                        onTap: submitQuiz,
                        btnWidth: MediaQuery.of(context).size.width,
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
