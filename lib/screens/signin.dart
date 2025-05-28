import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartexamprep/database/firebase_service.dart';
import 'package:smartexamprep/helper/local_storage.dart';
import 'package:smartexamprep/models/user_profile.dart';
import 'package:smartexamprep/screens/profile_screen.dart';
import 'package:smartexamprep/screens/singup.dart';

import '../helper/constants.dart';
import '../helper/helper_functions.dart';
import '../utils/validator_util.dart';
import '../widgets/app_bar.dart';
import '../widgets/custom_button.dart';
import 'forgot_password.dart';
import 'home.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailTextEditingController =
  TextEditingController();
  final TextEditingController passwordTextEditingController =
  TextEditingController();

  bool passwordVisible = true;

  bool isLoading = false;
  bool isBannerLoaded = false;
  //late BannerAd bannerAd;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        var user = await firebaseService.signInEmailAndPass(
            emailTextEditingController.text.trim(),
            passwordTextEditingController.text.trim());

        if (user != null) {
          if (kDebugMode) {
            print('Login user details:${user.userResponse.toString()}');
          }
          UserProfile userProfile= await firebaseService.getUserDetails(userId: user.userResponse!.uid);
          setState(() {
            isLoading = false;
          });

          await LocalStorage.saveUserLoggedInDetails(
              isLoggedIn: true, userId: userProfile.id!, userProfile: userProfile);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home(userProfile: userProfile)),
          );
        }
      } catch (err) {
        setState(() {
          isLoading = false;
        });

        debugPrint("Login error:: ${err.toString()}");
        // Ensure the context is still valid
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err.toString()),
              // Ensure the error message is shown
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void showSnackBarMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 600, right: 20, left: 20),
      ),
    );
  }

  //Clearing memory cache
  @override
  void dispose() {
    super.dispose();
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //bottomNavigationBar: const GetBannerAd(),
      appBar: AppBar(
        title: appBar(context),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
             // Constants.isMobileDevice? const GetBannerAd():const Text(""),
              const SizedBox(
                height: 50,
              ),
              Column(
                children: [
                  TextFormField(
                    controller: emailTextEditingController,
                    validator: (value) {
                      return validatorService.validateEmail(value);
                    },
                    decoration: const InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: passwordTextEditingController,
                    obscureText: passwordVisible,
                    validator: (value) {
                      return value!.isEmpty
                          ? Constants.passwordMessage
                          : value.length < 6
                          ? Constants.passwordLengthMessage
                          : null;
                    },
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(
                                () {
                              passwordVisible = !passwordVisible;
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen()));
                    },
                    child: Text(
                      "Forget Password?",
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _signIn();
                    },
                    child: customButton(
                      context: context,
                      btnLabel: "Sign in",
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(fontSize: 15.5),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUp()));
                        },
                        child: Text(
                          "Sign up",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue.shade900),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
