import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartexamprep/database/firebase_service.dart';
import 'package:smartexamprep/helper/local_storage.dart';
import 'package:smartexamprep/models/user_profile.dart';
import 'package:smartexamprep/screens/create_quiz.dart';
import 'package:smartexamprep/screens/profile_screen.dart';
import 'package:smartexamprep/screens/quiz_home.dart';
import 'package:smartexamprep/screens/signin.dart';

import '../helper/constants.dart';
import '../helper/helper_functions.dart';
import '../widgets/app_bar.dart';

class Home extends StatefulWidget {
  final UserProfile userProfile;

  const Home({super.key, required this.userProfile});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

  void _signOutFromQuiz() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () async {
                await firebaseService.signOut();
                await LocalStorage.resetAllPreferences();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignIn()),
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('No', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

/*  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await HelperFunctions.showBackDialog(
                context, Constants.brandName) ??
            false;
        if (context.mounted && shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: appBar(context),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
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
              icon: const Icon(Icons.logout),
              tooltip: "Logout",
              onPressed: () {
                _signOutFromQuiz();
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
                // Ensure refresh is possible
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: Constants.topicNames.length,
                itemBuilder: (context, index) {
                  final topic = Constants.topicNames[index];
                  final isActive = selectedTopicsList.contains(topic);

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: isActive ? Colors.greenAccent : Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          topic,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.black : Colors.grey[800],
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
                              backgroundColor: Colors.blue,
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
        floatingActionButton: userProfile.userRole == Constants.userRoles[0]
            ? null
            : FloatingActionButton(
                tooltip: "Add new quiz.",
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
      ),
    );
  }*/
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
        final bool shouldPop = await HelperFunctions.showBackDialog(
                context, Constants.brandName) ??
            false;
        if (context.mounted && shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: appBar(context),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
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
              icon: const Icon(Icons.logout),
              tooltip: "Logout",
              onPressed: () {
                _signOutFromQuiz();
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
                    color:
                        isActive ? Colors.greenAccent : Colors.green.shade100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          topic,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.black : Colors.grey[800],
                          ),
                        ),
                        if (isActive)
                          ElevatedButton(
                            onPressed: () async {
                              //Add here to navigate quiz the selected quiz home
                              debugPrint("Navigate quiz click: $topic");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          QuizHome(quizTitle: topic,userProfile:widget.userProfile)));
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => CreateQuiz(
                              //             userId: widget.userProfile.id!,topic: topic)));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text(
                              'Open',
                              style: TextStyle(color: Colors.white),
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
        floatingActionButton: userProfile.userRole == Constants.userRoles[0]
            ? null
            : FloatingActionButton(
                tooltip: "Add new quiz.",
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CreateQuiz(userId: widget.userProfile.id!)));
                },
                child: const Icon(Icons.add),
              ),
      ),
    );
  }
}
