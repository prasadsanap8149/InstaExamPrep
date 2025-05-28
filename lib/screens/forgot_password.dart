import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartexamprep/database/firebase_service.dart';
import 'package:smartexamprep/helper/api_constants.dart';
import 'package:smartexamprep/models/firebase_response.dart';

import '../helper/app_colors.dart';
import '../helper/helper_functions.dart';
import '../utils/validator_util.dart';
import '../widgets/app_bar.dart';
import '../widgets/custom_text_form_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      FirebaseResponse firebaseResponse =
          await firebaseService.resetPassword(_emailController.text.trim());

      if (firebaseResponse.statusCode == ApiConstants.success) {
        HelperFunctions.showSnackBarMessage(
          context: context,
          message: 'Password reset email sent to your email address.',
          color: AppColors.info,
        );
        Navigator.pop(context);
      } else {
        HelperFunctions.showSnackBarMessage(
          context: context,
          message: 'Please enter a valid email.',
          color: AppColors.error,
        );
      }
    } catch (e) {
      HelperFunctions.showSnackBarMessage(
        context: context,
        message: 'Error: $e',
        color: AppColors.error,
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             const Text(
                "It Happens! Let’s Reset",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 25),
              buildTextField(
                controller: _emailController,
                hintText: "Email",
                icon: Icons.email,
                validator: validatorService.validateEmail,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      _isSubmitting ? null : () => _resetPassword(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Reset Password",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.buttonText,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 16, color: AppColors.buttonText),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
