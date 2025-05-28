import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smartexamprep/helper/firebase_auth_error_messages.dart';
import 'package:smartexamprep/models/error_response.dart';
import 'package:smartexamprep/models/firebase_response.dart';
import 'package:smartexamprep/models/user_profile.dart';

import '../helper/api_constants.dart';
import '../helper/constants.dart';

class FirebaseService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseInstance = FirebaseFirestore.instance;

  // Create the new user
  Future<FirebaseResponse?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      if (kDebugMode) {
        print("signUpWithEmailAndPassword is called");
      }
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      FirebaseResponse firebaseResponse = FirebaseResponse(
          userResponse: userCredential.user,
          statusCode: ApiConstants.success,
          statusMessage: ApiConstants.successMessage);
      return firebaseResponse;
    } catch (e) {
      ErrorResponse errorResponse = ErrorResponse();
      if (kDebugMode) {
        print(e.toString());
      }
      debugPrint('Sign up error: $e');
      String errorMessage = 'Error signing up. Please try again later.';
      ErrorResponse(errorCode: "Exception", errorMessage: errorMessage);
      if (e is FirebaseAuthException) {
        errorMessage = FirebaseAuthErrorMessages.getErrorMessage(e.code);
        errorResponse =
            ErrorResponse(errorCode: e.code, errorMessage: errorMessage);
      }
      FirebaseResponse firebaseResponse = FirebaseResponse(
          errorResponse: errorResponse,
          statusCode: ApiConstants.fail,
          statusMessage: ApiConstants.successMessage);

      return firebaseResponse;
    }
  }

  Future<FirebaseResponse?> signInEmailAndPass(
      String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      FirebaseResponse firebaseResponse = FirebaseResponse(
          userResponse: userCredential.user,
          statusCode: ApiConstants.success,
          statusMessage: ApiConstants.successMessage);
      return firebaseResponse;
    } catch (e) {
      ErrorResponse errorResponse = ErrorResponse();
      if (kDebugMode) {
        print(e.toString());
      }
      debugPrint('Sign in error: $e');
      String errorMessage = 'Error signing in. Please try again later.';
      ErrorResponse(errorCode: "Exception", errorMessage: errorMessage);
      if (e is FirebaseAuthException) {
        errorMessage = FirebaseAuthErrorMessages.getErrorMessage(e.code);
        errorResponse =
            ErrorResponse(errorCode: e.code, errorMessage: errorMessage);
      }

      return FirebaseResponse(
          errorResponse: errorResponse,
          statusCode: ApiConstants.fail,
          statusMessage: ApiConstants.successMessage);
    }
  }
  signOut() async {
    try{
      await firebaseAuth.signOut();
    }catch(e){
      ErrorResponse errorResponse = ErrorResponse();
      if (kDebugMode) {
        print(e.toString());
      }
      debugPrint('Sign out error: $e');
      String errorMessage = 'Error signing out. Please try again later.';
      ErrorResponse(errorCode: "Exception", errorMessage: errorMessage);
      if (e is FirebaseAuthException) {
        errorMessage = FirebaseAuthErrorMessages.getErrorMessage(e.code);
        errorResponse =
            ErrorResponse(errorCode: e.code, errorMessage: errorMessage);
      }

    }
  }

  Future<FirebaseResponse> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return  FirebaseResponse(
          statusCode: ApiConstants.success,
          statusMessage: ApiConstants.successMessage);
    } catch (e) {
      ErrorResponse errorResponse = ErrorResponse();
      if (kDebugMode) {
        print(e.toString());
      }
      debugPrint('Sign in error: $e');
      String errorMessage = 'Error signing in. Please try again later.';
      ErrorResponse(errorCode: "Exception", errorMessage: errorMessage);
      if (e is FirebaseAuthException) {
        errorMessage = FirebaseAuthErrorMessages.getErrorMessage(e.code);
        errorResponse =
            ErrorResponse(errorCode: e.code, errorMessage: errorMessage);
      }

      return FirebaseResponse(
          errorResponse: errorResponse,
          statusCode: ApiConstants.fail,
          statusMessage: ApiConstants.successMessage);
    }
  }

  // Example method to save a user profile to Firebase
  Future<FirebaseResponse> saveUserProfile(
      {required UserProfile userProfile}) async {
    final collection =
        FirebaseFirestore.instance.collection(Constants.userCollection);

    try {
      await collection
          .doc(userProfile.id ?? collection.doc().id)
          .set(userProfile.toMap());
      return FirebaseResponse(
          statusCode: ApiConstants.success,
          statusMessage: ApiConstants.successMessage);
    } catch (e) {
      ErrorResponse errorResponse = ErrorResponse();
      if (kDebugMode) {
        print(e.toString());
      }
      debugPrint('Account creation error: $e');
      String errorMessage = 'Error account creation. Please try again later.';
      ErrorResponse(errorCode: "Exception", errorMessage: errorMessage);
      if (e is FirebaseAuthException) {
        errorMessage = FirebaseAuthErrorMessages.getErrorMessage(e.code);
        errorResponse =
            ErrorResponse(errorCode: e.code, errorMessage: errorMessage);
      }

      return FirebaseResponse(
          errorResponse: errorResponse,
          statusCode: ApiConstants.fail,
          statusMessage: ApiConstants.successMessage);
    }
  }

  Future<UserProfile> getUserDetails({required String userId}) async {
    DocumentSnapshot docSnapshot = await firebaseInstance
        .collection(Constants.userCollection)
        .doc(userId)
        .get();
    return UserProfile.fromMap(docSnapshot.data() as Map<String, dynamic>);
  }


}

final FirebaseService firebaseService = FirebaseService();
