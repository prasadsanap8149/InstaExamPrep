import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartexamprep/database/firebase_service.dart';
import 'package:smartexamprep/helper/local_storage.dart';
import 'package:smartexamprep/models/user_profile.dart';
import 'package:smartexamprep/screens/profile_screen.dart';
import 'package:smartexamprep/screens/quiz_home.dart';
import 'package:smartexamprep/screens/signin.dart';

import '../helper/app_colors.dart';
import '../helper/confirmation_messages.dart';
import '../helper/constants.dart';
import '../helper/helper_functions.dart';
import '../widgets/app_bar.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile userProfile;

  const HomeScreen({super.key, required this.userProfile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<String> selectedTopicsList;
  late UserProfile userProfile;

  @override
  void initState() {
    super.initState();
    selectedTopicsList = widget.userProfile.selectedTopics.toList();
    userProfile = widget.userProfile;
  }

  Future<void> _refreshTopics() async {
    // Simulate data fetch or refresh logic
    await Future.delayed(const Duration(seconds: 2));

    // Fetch updated user profile
    UserProfile? updatedProfile =
        await firebaseService.getUserDetails(userId: userProfile.id!);

    debugPrint("Refreshed User Profile: ${updatedProfile.toString()}");

    setState(() {
      userProfile = updatedProfile; // Assign the updated profile
      selectedTopicsList =
          userProfile.selectedTopics.toList(); // Update the topic list
    });
  }

  Future<void> _signOutFromQuiz(BuildContext context) async {
    final bool shouldSignOut = await HelperFunctions.showCustomDialog(
          context,
          ConfirmationMessages.signOutTitle,
          ConfirmationMessages.signOutMessage,
        ) ??
        false;

    // Use `mounted` to avoid context issues after async gaps
    if (!context.mounted) return;

    if (shouldSignOut) {
      await firebaseService.signOut();
      await LocalStorage.resetAllPreferences();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignIn()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Separate active and inactive topics
    final List<String> activeTopics = Constants.topicNames
        .where((topic) => selectedTopicsList.contains(topic))
        .toList();
    final List<String> inactiveTopics = Constants.topicNames
        .where((topic) => !selectedTopicsList.contains(topic))
        .toList();

    // Combine active topics followed by inactive topics
    final List<String> orderedTopics = [...activeTopics, ...inactiveTopics];

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await HelperFunctions.showCustomDialog(
                context,
                ConfirmationMessages.exitAppTitle,
                ConfirmationMessages.exitAppMessage) ??
            false;
        if (context.mounted && shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: appBar(context),
          centerTitle: true,
          backgroundColor: AppColors.appBarBackground,
          elevation: 0.0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle,color: AppColors.fabIconColor,),
              color: AppColors.appBarIcon,
              tooltip: "Profile",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                            profileDetails: widget.userProfile,
                          )),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout,color: AppColors.fabIconColor,),
              color: AppColors.appBarIcon,
              tooltip: "Logout",
              onPressed: () {
                _signOutFromQuiz(context);
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshTopics,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: orderedTopics.length,
                itemBuilder: (context, index) {
                  final topic = orderedTopics[index];
                  final isActive = selectedTopicsList.contains(topic);

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: AppColors.cardPrimary,
                    //isActive ? Colors.green.shade100 : Colors.green[800],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          topic,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            color: AppColors.accent,),
                        ),
                        if (isActive)
                          ElevatedButton(
                            onPressed: () async {
                              //Add here to navigate quiz the selected quiz home
                              debugPrint("Navigate quiz click: $topic");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QuizHome(
                                          quizTitle: topic,
                                          userProfile: widget.userProfile)));

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Open',
                              style: TextStyle(color: AppColors.iconPrimary),
                            ),
                          ),
                        if (!isActive)
                          ElevatedButton(
                            onPressed: () async {
                              // Add topic to selectedTopicsList and update database
                              setState(() {
                                selectedTopicsList.add(topic);
                              });

                              // await firebaseService.updateUserTopics(
                              //   userId: userProfile.id!,
                              //   updatedTopics: selectedTopicsList,
                              // );

                              debugPrint("Added topic: $topic");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        // floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        // floatingActionButton: widget.userProfile.userRole ==
        //         Constants.userRoles[0]
        //     ? null
        //     : InkWell(
        //         onTap: () {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) =>
        //                   CreateQuizRoom(userId: widget.userProfile.id!),
        //             ),
        //           );
        //         },
        //         child: Container(
        //           padding:
        //               const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        //           decoration: BoxDecoration(
        //             color: Colors.blueAccent,
        //             borderRadius: BorderRadius.circular(12),
        //             boxShadow: const [
        //               BoxShadow(
        //                 color: Colors.black26,
        //                 blurRadius: 8,
        //                 offset: Offset(2, 4),
        //               ),
        //             ],
        //           ),
        //           child: const Row(
        //             mainAxisSize: MainAxisSize.min,
        //             children: [
        //               Icon(Icons.add_circle_outline, color: Colors.white),
        //               SizedBox(width: 8),
        //               Text(
        //                 'Create Room',
        //                 style: TextStyle(
        //                   fontSize: 16,
        //                   fontWeight: FontWeight.bold,
        //                   color: Colors.white,
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
      ),
    );
  }
}
