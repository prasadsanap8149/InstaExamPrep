import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartexamprep/database/firebase_service.dart';
import 'package:smartexamprep/helper/helper_functions.dart';
import 'package:smartexamprep/helper/local_storage.dart';
import 'package:smartexamprep/screens/singup.dart';

import '../helper/app_colors.dart';
import '../helper/constants.dart';
import '../utils/validator_util.dart';
import '../widgets/app_bar.dart';
import '../widgets/custom_text_form_field.dart';
import 'forgot_password.dart';
import 'home_screen.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();

  bool passwordVisible = true;
  bool isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
    )..forward();

    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final user = await firebaseService.signInEmailAndPass(
          emailTextEditingController.text.trim(),
          passwordTextEditingController.text.trim(),
          context,
        );
        debugPrint('LOGIN RESPONSE::$user');
        if (user != null && user.userResponse != null) {
          final userProfile = await firebaseService.getUserDetails(
            userId: user.userResponse!.uid,
          );

          await LocalStorage.saveUserLoggedInDetails(
            isLoggedIn: true,
            userId: userProfile.id!,
            userProfile: userProfile,
          );

          if (mounted) {
            setState(() => isLoading = false);
            HelperFunctions.showSnackBarMessage(
                context: context,
                message: "Signed in successfully",
                color: Colors.green);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => HomeScreen(userProfile: userProfile)),
            );
          }
        } else {
          // Handle the null case
          if (mounted) {
            setState(() => isLoading = false);
            HelperFunctions.showSnackBarMessage(
                context: context,
                message: "Something went wrong. Please try again.",
                color: Colors.red);
          }
        }

        /* if (user != null) {
          final userProfile = await firebaseService.getUserDetails(
            userId: user.userResponse!.uid,
          );

          await LocalStorage.saveUserLoggedInDetails(
            isLoggedIn: true,
            userId: userProfile.id!,
            userProfile: userProfile,
          );

          if (mounted) {
            setState(() => isLoading = false);
            HelperFunctions.showSnackBarMessage(
                context: context,
                message: "Signed in successfully",
                color: Colors.green);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => HomeScreen(userProfile: userProfile)),
            );
          }
        }*/
      } catch (err) {
        if (mounted) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Error: ${err.toString()}"),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
    super.dispose();
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            buildTextField(
                              controller: emailTextEditingController,
                              hintText: "Email",
                              icon: Icons.email,
                              validator: validatorService.validateEmail,
                            ),
                            const SizedBox(height: 16),
                            buildTextField(
                              controller: passwordTextEditingController,
                              hintText: "Password",
                              icon: Icons.lock,
                              obscureText: passwordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    passwordVisible = !passwordVisible;
                                  });
                                },
                              ),
                              validator: (value) => value!.isEmpty
                                  ? Constants.passwordMessage
                                  : value.length < 6
                                      ? Constants.passwordLengthMessage
                                      : null,
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Forget Password?",
                                  style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _signIn,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                  backgroundColor: AppColors.buttonBackground,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Sign In",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.buttonText),
                                      ),
                              ),
                              /*ElevatedButton(
                                onPressed: isLoading ? null : _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  disabledBackgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Sign In",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.buttonText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),*/
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?",
                              style: TextStyle(fontSize: 15.5)),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SignUp()),
                              );
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

      /* body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(height: 50),
                    Column(
                      children: [
                        TextFormField(
                          controller: emailTextEditingController,
                          style: const TextStyle(color: AppColors.accent),
                          validator: (value) =>
                              validatorService.validateEmail(value),
                          decoration: const InputDecoration(
                            hintText: "Email",
                            prefixIcon: Icon(Icons.email,
                                color: AppColors.fabIconColor),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: passwordTextEditingController,
                          style: const TextStyle(color: AppColors.accent),
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
                            prefixIcon: const Icon(Icons.lock,
                                color: AppColors.fabIconColor),
                            suffixIcon: IconButton(
                              icon: Icon(passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () => setState(
                                  () => passwordVisible = !passwordVisible),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ForgotPasswordScreen()));
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.buttonText,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?",
                                style: TextStyle(fontSize: 15.5)),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const SignUp()));
                              },
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),*/
    );
  }
}
