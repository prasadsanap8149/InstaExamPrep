import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../helper/app_colors.dart';
import '../../helper/helper_functions.dart';
import '../../models/quiz_answer_list.dart';

class ReportScreen extends StatefulWidget {
  final Map<String, QuizAnswerList> userAnswers;

  const ReportScreen({
    super.key,
    required this.userAnswers,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late int score;
  bool showDetailedView = true;

  @override
  void initState() {
    super.initState();
    score =
        widget.userAnswers.values.where((answer) => answer.isCorrect).length;
    debugPrint(
        'Data Received in Report Screen::\n${widget.userAnswers.toString()}');
  }

  void toggleView() {
    setState(() => showDetailedView = !showDetailedView);
  }

  void shareResults() {
    final total = widget.userAnswers.length;
    final resultText = 'I scored $score out of $total in my quiz! 🎯💡';
    Share.share(resultText);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.userAnswers.length;
    final percentage = (score / total * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Report'),
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.accent,
        centerTitle: true,
        automaticallyImplyLeading: false,
        /*actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded, color: AppColors.fabIconColor),
            tooltip: "Exit",
            onPressed: () async {
              final bool shouldExit = await HelperFunctions.showCustomDialog(
                context,
                "Exit Exam",
                "Are you sure you want to exit the exam? Your progress may be lost.",
              ) ??
                  false;

              if (!context.mounted) return;
              if (shouldExit) Navigator.pop(context);
            },
          ),
        ],*/
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Score Card with Circular % View
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade200, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blue.shade100,
                      blurRadius: 8,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Text('Your Score',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                    '$score / $total',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: score / total,
                    backgroundColor: Colors.white30,
                    color: Colors.white,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text('$percentage%',
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Toggle View Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Detailed View"),
                  selected: showDetailedView,
                  onSelected: (_) => setState(() => showDetailedView = true),
                  selectedColor: Colors.blue.shade100,
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text("Score View"),
                  selected: !showDetailedView,
                  onSelected: (_) => setState(() => showDetailedView = false),
                  selectedColor: Colors.grey.shade300,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question List Section
            Expanded(
              child: showDetailedView
                  ? ListView.builder(
                      itemCount: widget.userAnswers.length,
                      itemBuilder: (context, index) {
                        final quizAnswer =
                            widget.userAnswers.values.elementAt(index);
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Q${index + 1}: ${quizAnswer.content}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: quizAnswer.options.map((option) {
                                    final isCorrect = option.isCorrect;
                                    final isSelected =
                                        quizAnswer.selectedOption ==
                                            option.option;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSelected
                                                ? (isCorrect
                                                    ? Icons.check_circle
                                                    : Icons.cancel)
                                                : Icons.circle_outlined,
                                            color: isSelected
                                                ? (isCorrect
                                                    ? Colors.green
                                                    : Colors.red)
                                                : Colors.grey,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${option.option} ${isCorrect ? "(Correct)" : ""}',
                                              style: TextStyle(
                                                color: isSelected
                                                    ? (isCorrect
                                                        ? Colors.green
                                                        : Colors.red)
                                                    : Colors.black,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                if (quizAnswer.explanation.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text('Explanation: ${quizAnswer.explanation}',
                                      style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey)),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'Your score is $score out of $total\n($percentage%)',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
            ),

            // Share / Exit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: shareResults,
                  icon: const Icon(Icons.share, color: AppColors.fabIconColor),
                  label: const Text(
                    'Share Results',
                    style: TextStyle(color: AppColors.buttonText),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fabBackground),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
