// import 'dart:async';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:smartexamprep/services/question_provider.dart';
//
// import '../helper/constants.dart';
// import '../models/question.dart';
//
// class QuizPlayDynamic extends StatelessWidget {
//   final String quizId;
//
//   const QuizPlayDynamic({super.key, required this.quizId});
//
//   Future<List<Question>> fetchQuestions(String quizId) async {
//     final querySnapshot = await FirebaseFirestore.instance
//         .collection(Constants.quizCollection)
//         .doc(quizId)
//         .collection('questions')
//         .get();
//     return querySnapshot.docs
//         .map((doc) => Question.fromMap(doc.data()))
//         .toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => QuestionProvider(),
//       child: Scaffold(
//         appBar: AppBar(title: const Text('Quiz')),
//         body: FutureBuilder<List<Question>>(
//           future: fetchQuestions(quizId),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return const Center(child: Text('Error loading questions'));
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return const Center(child: Text('No questions available'));
//             } else {
//               //context.read<QuestionProvider>().loadQuestions(snapshot.data!);
//               return const QuizContent();
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class QuizContent extends StatelessWidget {
//   const QuizContent({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<QuestionProvider>();
//     // final currentQuestion = provider.questions[provider.currentQuestionIndex];
//     //
//     // if (provider.isQuizSubmitted) {
//     //   return const QuizSummary();
//     // }
//
//     return Column(
//       children: [
//         Text('Question ${provider.currentQuestionIndex + 1}/${provider.questions.length}',
//             style: Theme.of(context).textTheme.titleLarge),
//         const SizedBox(height: 10),
//         Text(currentQuestion.content, style: Theme.of(context).textTheme.bodyLarge),
//         const SizedBox(height: 20),
//         ...currentQuestion.options.map((option) {
//           return ListTile(
//             title: Text(option.content),
//             leading: Radio<String>(
//               value: option.id,
//               groupValue: provider.userAnswers[currentQuestion.id],
//               onChanged: (value) {
//                 provider.setAnswer(currentQuestion.id, value!);
//               },
//             ),
//           );
//         }).toList(),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             ElevatedButton(
//               onPressed: provider.currentQuestionIndex > 0
//                   ? provider.previousQuestion
//                   : null,
//               child: const Text('Previous'),
//             ),
//             ElevatedButton(
//               onPressed: provider.currentQuestionIndex < provider.questions.length - 1
//                   ? provider.nextQuestion
//                   : null,
//               child: const Text('Next'),
//             ),
//           ],
//         ),
//         if (provider.currentQuestionIndex == provider.questions.length - 1)
//           ElevatedButton(
//             onPressed: provider.submitQuiz,
//             child: const Text('Submit Quiz'),
//           ),
//       ],
//     );
//   }
// }
//
// class QuizSummary extends StatelessWidget {
//   const QuizSummary({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<QuizProvider>();
//     final correctAnswers = provider.calculateCorrectAnswers();
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text('Quiz Completed!', style: Theme.of(context).textTheme.headlineSmall),
//           Text('Correct Answers: $correctAnswers/${provider.questions.length}',
//               style: Theme.of(context).textTheme.bodyLarge),
//         ],
//       ),
//     );
//   }
// }
