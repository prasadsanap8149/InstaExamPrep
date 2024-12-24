import 'package:flutter/material.dart';
import 'package:smartexamprep/screens/dynamic_question_form.dart';
import 'package:smartexamprep/screens/question_form.dart';

import '../helper/constants.dart';
import '../models/quiz.dart';

class QuizTile extends StatelessWidget {
  final String imgUrl;
  final int index;
  final String userType;
  final Quiz quizMap;
  final String userId;

  const QuizTile({
    super.key,
    required this.quizMap,
    required this.imgUrl,
    required this.userType,
    required this.index,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (userType != Constants.userRoles[1]) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Choose Action'),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.teal,
                        ),
                        onPressed: () {
                          Navigator.pop(
                              context); // This pop is for the alert dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddQuestionsDynamic()// DynamicQuestionForm(userId:userId,quiz: quizMap,),
                            ),
                          );
                        },
                        child: const Text('Add Questions'),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.amber,
                        ),
                        onPressed: () {
                          Navigator.pop(
                              context); // This pop is for the alert dialog
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => QuizPlayDynamic(
                          //       quizId: quizMap.id,
                          //     ),
                          //   ),
                          // );
                        },
                        child: const Text('Play Quiz'),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        } else {
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => QuizPlayDynamic(
          //       quizId: quizMap.id,
          //     ),
          //   ),
          // );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.greenAccent,
        child: Padding(
          // Added padding inside the QuizTile
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white70,
                  radius: 16,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  quizMap.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                // Added spacing between title and description
                Text(
                  quizMap.quizDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class QuizGridView extends StatelessWidget {
//   final List<dynamic> quizList;
//   final String userLoginId;
//   final String userType;
//
//   const QuizGridView({
//     super.key,
//     required this.quizList,
//     required this.userLoginId,
//     required this.userType,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       // Added padding around the entire GridView
//       padding: const EdgeInsets.all(16.0),
//       child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 3 / 2,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//         ),
//         itemCount: quizList.length,
//         itemBuilder: (context, index) {
//           var data = quizList[index].data() as Map<String, dynamic>;
//
//           return QuizTile(
//             imgUrl: Constants.imageUrl,
//             userType: userType,
//             index: index, quizMap: widget.qui,
//           );
//         },
//       ),
//     );
//   }
// }
