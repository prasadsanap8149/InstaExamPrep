import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartexamprep/helper/helper_functions.dart';

import '../database/firebase_service.dart';
import '../helper/app_colors.dart';
import '../models/question.dart';
import '../widgets/custom_confirmation_dialog.dart';

class ViewQuestionList extends StatefulWidget {
  final List<Questions> questionList;
  final String quizId;

  const ViewQuestionList(
      {super.key, required this.questionList, required this.quizId});

  @override
  State<ViewQuestionList> createState() => _ViewQuestionListState();
}

class _ViewQuestionListState extends State<ViewQuestionList> {
  void deleteQuestion(String questionId) async {
    // Filter out the question with the matching ID
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomConfirmationDialog(
          title: 'Delete Item',
          message: 'Are you sure you want to delete this item?',
          confirmButtonText: 'Delete',
          cancelButtonText: 'Cancel',
          onConfirm: () async {
            setState(() {
              widget.questionList
                  .removeWhere((question) => question.id == questionId);
            });

            try {
              // Update the questions in Firebase after deletion
              await firebaseService.deleteRecord(widget.quizId, questionId);
              debugPrint('Question deleted successfully');
            } catch (e) {
              debugPrint('Error deleting question: $e');
            }
          },
          onCancel: () {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Questions List"),
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.accent,
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: widget.questionList.isEmpty
          ? const Center(
              child: Text('No Question Added Yet'),
            )
          : ListView.builder(
        itemCount: widget.questionList.length,
        itemBuilder: (context, index) {
          final question = widget.questionList[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Metadata
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'ID: ${question.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Chip(
                        label: Text(
                          question.type!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: question.type == 'Multiple Choice'
                            ? Colors.blueAccent
                            : Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.fabIconColor, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Difficulty: ${question.difficultyLevel}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1, height: 24),

                  // Questions List
                  ...?question.questionsList?.map((ql) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: [
                            Chip(
                              label: Text(
                                'Lang: ${ql.language}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ql.content!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Options:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...ql.options!.map((option) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                Icon(
                                  option.isCorrect
                                      ? Icons.check_circle_outline
                                      : Icons.cancel_outlined,
                                  color: option.isCorrect ? Colors.green : Colors.red,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    option.option,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 6),
                        Text(
                          'Explanation: ${ql.explanation}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                        const Divider(thickness: 1, color: Colors.grey, height: 24),
                      ],
                    );
                  }).toList(),

                  // Action Buttons
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            HelperFunctions.showSnackBarMessage(
                              context: context,
                              message:
                              'This option not enabled yet. Please delete existing and save again',
                              color: Colors.orangeAccent,
                            );
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text('Update'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            deleteQuestion(question.id!);
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      )
      ,
    );
  }
}
