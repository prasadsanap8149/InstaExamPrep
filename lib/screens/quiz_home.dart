import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartexamprep/models/quiz.dart';
import 'package:smartexamprep/models/user_profile.dart';

import '../database/firebase_service.dart';
import '../helper/constants.dart';
import '../widgets/app_bar.dart';
import '../widgets/quiz_tile.dart';

class QuizHome extends StatefulWidget {
  final String quizTitle;
  final UserProfile userProfile;

  const QuizHome(
      {super.key, required this.quizTitle, required this.userProfile});

  @override
  State<QuizHome> createState() => _QuizHomeState();
}

class _QuizHomeState extends State<QuizHome> {
  late Stream quizStream;
  late String userType = Constants.userRoles[0];

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  Widget quizList(bool userFlag, String quizInterest) {
    return StreamBuilder(
      stream: firebaseService.getQuizStream(userFlag, quizInterest),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // Show a loading indicator during the debounce time
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // After debounce time, check if data is available
        return !snapshot.hasData || snapshot.data!.docs.isEmpty
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Constants.isMobileDevice
                  //     ? const GetBannerAd()
                  //     : const Text(""),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.insert_emoticon_rounded,
                          size: 100.0,
                          color: Colors.greenAccent,
                        ),
                        Text(
                          "Quiz Coming Soon...",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  Quiz quizMap = Quiz.fromMap(doc.data() as Map<String,dynamic>);
                  debugPrint('Quiz Home User ID:${widget.userProfile.id}');
                  debugPrint('Fetch quiz document :: ${doc.data()}');
                  return QuizTile(
                    imgUrl: Constants.imageUrl,
                    userType: userType,
                    userId: widget.userProfile.id.toString(),
                    index: index, quizMap: quizMap,
                  );
                },
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBar(context),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: quizList(
            widget.userProfile.userRole == Constants.userRoles[0]
                ? false
                : true,
            widget.quizTitle),
      ),
      floatingActionButton:
          widget.userProfile.userRole == Constants.userRoles[0]
              ? null
              : FloatingActionButton(
                  tooltip: "Add new quiz.",
                  onPressed: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) =>
                    //             CreateQuiz(userId: userLoginId.toString())));
                  },
                  child: const Icon(Icons.add),
                ),
    );
  }
}
