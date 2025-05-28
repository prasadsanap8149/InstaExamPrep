import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:smartexamprep/database/firebase_service.dart';
import 'package:smartexamprep/helper/api_constants.dart';
import 'package:smartexamprep/models/firebase_response.dart';
import 'package:smartexamprep/screens/signin.dart';

import '../helper/helper_functions.dart';
import '../utils/validator_util.dart';
import '../widgets/app_bar.dart';
import '../widgets/custom_button.dart';



class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ForgotPasswordScreen({super.key});

   _resetPassword(BuildContext context)  async {
    try {
      if(_emailController.text.isNotEmpty) {
        FirebaseResponse firebaseResponse = await firebaseService.resetPassword(_emailController.text.trim());
        if(firebaseResponse.statusCode==ApiConstants.success) {
          HelperFunctions.showSnackBarMessage(context: context,
              message: 'Password reset email sent to you email address.',
              color: Colors.greenAccent);
        }else{
          HelperFunctions.showSnackBarMessage(context: context,
              message: firebaseResponse.statusMessage,
              color: Colors.redAccent);
        }
      }else{
        HelperFunctions.showSnackBarMessage(context: context, message: 'Please enter the valid email' ,color: Colors.redAccent);
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: appBar(context),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              keyboardType: TextInputType.visiblePassword,
              validator: (value) {
                return validatorService.validateEmail(value);
              },
              decoration: const InputDecoration(
                hintText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
              controller: _emailController,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _resetPassword(context);
              },
              child: customButton(
                context: context,
                btnLabel: "Reset Password",
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignIn()));
              },
              child: customButton(
                context: context,
                btnLabel: "Sign In",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
