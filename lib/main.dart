import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:smartexamprep/core/di/dependency_injection.dart';
import 'package:smartexamprep/core/error/error_handler.dart';
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
  
  // Initialize Firebase first, then run app with error handling
  await _initializeApp();
  
  // Set up global error handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    ErrorHandler.logError(
      details.exception, 
      stackTrace: details.stack, 
      context: 'Flutter Error'
    );
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // Handle errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorHandler.logError(error, stackTrace: stack, context: 'Platform Error');
    debugPrint('Platform Error: $error');
    return true;
  };
  
  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  try {
    // Load environment configuration
    await _loadEnvironmentConfig();
    
    // Initialize Firebase with retry mechanism
    await _initializeFirebaseWithRetry();
    
  } catch (e) {
    debugPrint('App initialization failed: $e');
    // Log critical errors but continue app startup
  }
}

Future<void> _loadEnvironmentConfig() async {
  const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );
  
  final String envFileName = environment == 'prod' ? '.env.prod' : '.env.dev';
  
  try {
    await dotenv.load(fileName: envFileName);
    debugPrint('Successfully loaded $envFileName');
  } catch (e) {
    debugPrint('Could not load $envFileName: $e');
    // Continue without env file if not found
  }
}

Future<void> _initializeFirebaseWithRetry({int maxRetries = 3}) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      if (kIsWeb) {
        debugPrint("Initializing Firebase for Web (attempt $attempt)");
        await Firebase.initializeApp(
          options: FirebaseOptionKeys.firebaseWebOptions,
        );
      } else {
        debugPrint("Initializing Firebase for Mobile (attempt $attempt)");
        if (Platform.isAndroid) {
          await Firebase.initializeApp(
            options: FirebaseOptionKeys.firebaseAndroidOptions,
          );
        } else {
          await Firebase.initializeApp(
            options: FirebaseOptionKeys.firebaseIOSOptions,
          );
        }
      }
      
      debugPrint("Firebase initialization successful");
      return; // Success, exit retry loop
      
    } catch (e) {
      debugPrint("Firebase initialization error (attempt $attempt): $e");
      
      if (attempt == maxRetries) {
        debugPrint("Firebase initialization failed after $maxRetries attempts");
        rethrow; // Throw on final attempt
      }
      
      // Wait before retry
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }
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
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      await checkConnectivity();
      await getLoggedInState();
    } catch (e) {
      ErrorHandler.logError(e, context: '_initializeApp');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Check network connectivity with proper stream handling
  Future<void> checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (mounted) {
        setState(() {
          _isOnline = !connectivityResult.contains(ConnectivityResult.none);
        });
      }

      // Listen for connectivity changes with proper error handling
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        (List<ConnectivityResult> result) {
          if (mounted) {
            final isOnline = !result.contains(ConnectivityResult.none);
            setState(() {
              _isOnline = isOnline;
            });
            
            // Handle connectivity changes
            _handleConnectivityChange(isOnline);
          }
        },
        onError: (error) {
          if (kDebugMode) {
            print("Connectivity stream error: $error");
          }
        },
      );
    } catch (error) {
      if (kDebugMode) {
        print("Error checking connectivity: $error");
      }
      // Default to offline if connectivity check fails
      if (mounted) {
        setState(() {
          _isOnline = false;
        });
      }
    }
  }

  void _handleConnectivityChange(bool isOnline) {
    if (isOnline && _isUserLoggedIn && userProfile == null) {
      // If we came back online and user is logged in but no profile, try to fetch it
      getLoggedInUserID();
    }
  }

  Future<void> getLoggedInState() async {
    if (kDebugMode) {
      print("Fetching logged-in state...");
    }

    try {
      final isLoggedIn = await LocalStorage.getUserLoggedInDetails();
      if (mounted) {
        setState(() {
          _isUserLoggedIn = isLoggedIn ?? false;
        });

        if (_isUserLoggedIn && _isOnline) {
          await getLoggedInUserID();
        } else if (!_isOnline) {
          if (kDebugMode) {
            print("App is offline. Loading cached user profile...");
          }
          // Load cached user profile when offline
          await loadCachedUserProfile();
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching logged-in state: $error");
      }
      // Handle error gracefully
      if (mounted) {
        setState(() {
          _isUserLoggedIn = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Data fetching complete
        });
      }
    }
  }

  Future<void> loadCachedUserProfile() async {
    try {
      final cachedProfile = await LocalStorage.getUserProfile();
      if (cachedProfile != null && mounted) {
        setState(() {
          userProfile = cachedProfile;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error loading cached user profile: $error");
      }
    }
  }

  Future<void> getLoggedInUserID() async {
    try {
      String? userLoginIdDetails = await LocalStorage.getUserLoginIdDetails();
      if (userLoginIdDetails == null) {
        throw Exception('User ID not found in local storage');
      }
      
      if (kDebugMode) {
        print("Logged-in user: $userLoginIdDetails");
      }

      final user = await firebaseService.getUserDetails(userId: userLoginIdDetails);
      
      if (mounted) {
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
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching user details: $error");
      }
      
      // Try to load cached profile as fallback
      await loadCachedUserProfile();
      
      // If still no profile and we're online, sign out user
      if (userProfile == null && _isOnline && mounted) {
        setState(() {
          _isUserLoggedIn = false;
        });
        await LocalStorage.resetAllPreferences();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white, // or any themed color
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue), // use theme color
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading, please wait...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_isOnline) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
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

    return MultiProvider(
      providers: DependencyInjection.getProviders(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'InstaExamPrep',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: _buildHomeScreen(),
      ),
    );
  }

  Widget _buildHomeScreen() {
    if (_isUserLoggedIn && userProfile != null) {
      return HomeScreen(userProfile: userProfile!);
    } else {
      return const SignUp();
    }
  }
}
