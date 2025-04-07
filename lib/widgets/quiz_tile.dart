import 'package:flutter/material.dart';
import 'package:smartexamprep/helper/app_colors.dart';
import 'package:smartexamprep/screens/question_form.dart';
import 'package:smartexamprep/screens/quiz_play_screen/quiz_play_screen.dart';

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
                                builder: (context) => AddQuestionsDynamic(
                                      userId: userId,
                                      quizId: quizMap.id,
                                    ) // DynamicQuestionForm(userId:userId,quiz: quizMap,),
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizPlayScreen(
                                quizId: quizMap.id,
                                userId: userId,
                                duration: Duration(
                                    hours: quizMap.hour,
                                    minutes: quizMap.minute,
                                    seconds: 0),
                              ),
                            ),
                          );
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPlayScreen(
                quizId: quizMap.id,
                userId: userId,
                duration: Duration(
                    hours: quizMap.hour, minutes: quizMap.minute, seconds: 0),
              ),
            ),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: AppColors.cardPrimary,
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Increased padding for better spacing
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor:AppColors.primary,
                radius: 16,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                quizMap.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              // const SizedBox(height: 6),
              // Text(
              //   quizMap.quizDescription,
              //   textAlign: TextAlign.center,
              //   style: const TextStyle(
              //     fontSize: 14,
              //     color: Colors.black54,
              //   ),
              // ),
              const SizedBox(height: 12),

              // Button Row for Start, Details, Add
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            title: const Text(
                              "Quiz Details",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: SizedBox(
                              height: 200, // Fixed height for the scrollable content
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Title: ${quizMap.title}",
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Description:",
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.grey.shade200,
                                      ),
                                      child: Text(
                                        quizMap.quizDescription,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),

                                    const SizedBox(height: 8),
                                    quizMap.hour > 0 ?
                                    Text(
                                      "Time Limit: ${quizMap.hour} Hour ${quizMap.minute} Min",
                                      style: const TextStyle(fontSize: 14),
                                    ):Text(
                                      "Time Limit: ${quizMap.minute} Min",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the popup
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all<Color>(Colors.redAccent),
                                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                                  padding: WidgetStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                child: const Text("Close"),
                              ),

                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.info, color: AppColors.fabIconColor,),
                    label: const Text(
                      "Details",
                      style: TextStyle(color: AppColors.buttonText),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      //Navigator.pop(context); // This pop is for the alert dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizPlayScreen(
                            quizId: quizMap.id,
                            userId: userId,
                            duration: Duration(
                                hours: quizMap.hour,
                                minutes: quizMap.minute,
                                seconds: 0),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow, color: AppColors.fabIconColor,),
                    label: const Text(
                      "Start",
                      style: TextStyle(color: AppColors.buttonText),
                    ),
                  ),

                  if (userType != Constants.userRoles[2])
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                            context); // This pop is for the alert dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddQuestionsDynamic(
                                    userId: userId,
                                    quizId: quizMap.id,
                                  ) // DynamicQuestionForm(userId:userId,quiz: quizMap,),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonBackground,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add, color: AppColors.fabIconColor,),
                      label: const Text(
                        "Add",
                        style: TextStyle(color: AppColors.buttonText),
                      ),
                    ),


                ],
              ),
            ],
          ),
        ),
      ),

      // child: Card(
      //   elevation: 4,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(10),
      //   ),
      //   color: Colors.greenAccent,
      //   child: Padding(
      //     // Added padding inside the QuizTile
      //     padding: const EdgeInsets.all(8.0),
      //     child: Center(
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           CircleAvatar(
      //             backgroundColor: Colors.white70,
      //             radius: 16,
      //             child: Text(
      //               '${index + 1}',
      //               style: const TextStyle(
      //                 color: Colors.black87,
      //                 fontWeight: FontWeight.bold,
      //               ),
      //             ),
      //           ),
      //
      //           Text(
      //             quizMap.title.toUpperCase(),
      //             textAlign: TextAlign.center,
      //             style: const TextStyle(
      //               fontSize: 18,
      //               fontWeight: FontWeight.bold,
      //               color: Colors.black,
      //             ),
      //           ),
      //           const SizedBox(height: 8),
      //           // Added spacing between title and description
      //           Text(
      //             quizMap.quizDescription,
      //             textAlign: TextAlign.center,
      //             style: const TextStyle(
      //               fontSize: 14,
      //               color: Colors.black54,
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
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
