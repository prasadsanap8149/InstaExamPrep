import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartexamprep/helper/firebase_option_keys.dart';
import 'package:smartexamprep/helper/local_storage.dart';
import 'package:smartexamprep/models/user_profile.dart';
import 'package:smartexamprep/screens/home_screen.dart';
import 'package:smartexamprep/screens/offline_screen.dart';
import 'package:smartexamprep/screens/singup.dart';
import 'package:smartexamprep/widgets/app_bar.dart';

import 'database/firebase_service.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      if (kDebugMode) {
        print("Initializing Firebase for Web");
      }
      await Firebase.initializeApp(
        options: FirebaseOptionKeys.firebaseWebOptions,
      );
    } else {
      if (kDebugMode) {
        print("Initializing Firebase for Mobile Device");
      }
      if (Platform.isAndroid) {
        debugPrint('Android device detected');
        await Firebase.initializeApp(
          options: FirebaseOptionKeys.firebaseAndroidOptions,
        );
      } else {
        await Firebase.initializeApp(
          options: FirebaseOptionKeys.firebaseIOSOptions,
        );
      }

      if (kDebugMode) {
        print("Firebase initialization is done");
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print("Firebase initialization error: $e");
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isUserLoggedIn = false;
  bool _isLoading = true;
  UserProfile? userProfile;
  bool _isOnline = true; // Indicates network status

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    getLoggedInState();
  }

  // Check network connectivity
  Future<void> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((connectivityResult) {
      setState(() {
        _isOnline = connectivityResult != ConnectivityResult.none;
      });
    });
  }

  Future<void> getLoggedInState() async {
    if (kDebugMode) {
      print("Fetching logged-in state...");
    }

    try {
      final isLoggedIn = await LocalStorage.getUserLoggedInDetails();
      setState(() {
        _isUserLoggedIn = isLoggedIn ?? false;
      });

      if (_isUserLoggedIn) {
        if (_isOnline) {
          await getLoggedInUserID();
        } else {
          if (kDebugMode) {
            print(
                "App is offline. Unable to fetch user profile from Firebase.");
          }
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching logged-in state: $error");
      }
    } finally {
      setState(() {
        _isLoading = false; // Data fetching complete
      });
    }
  }

  Future<void> getLoggedInUserID() async {
    try {
      String? userLoginIdDetails = await LocalStorage.getUserLoginIdDetails();
      if (kDebugMode) {
        print("Logged-in user: $userLoginIdDetails");
      }

      final user =
      await firebaseService.getUserDetails(userId: userLoginIdDetails!);
      await LocalStorage.saveUserLoggedInDetails(
        isLoggedIn: true,
        userId: user.id!,
        userProfile: user,
      );

      setState(() {
        userProfile = user; // Assign the user profile
      });

      if (kDebugMode) {
        print("Logged-in user details: ${userProfile.toString()}");
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching user details: $error");
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isOnline) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: appBar(context),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          body: const OfflineScreen(),
        ),
      );
    }

    return MaterialApp(
      title: '',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _isUserLoggedIn
          ? (userProfile != null
          ? HomeScreen(userProfile: userProfile!)
          : const Center(
        child:  SignUp(),
      ))
          : const SignUp(),
    );
  }
}

