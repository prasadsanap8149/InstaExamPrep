import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartexamprep/helper/firebase_auth_error_messages.dart';
import 'package:smartexamprep/models/error_response.dart';
import 'package:smartexamprep/models/firebase_response.dart';
import 'package:smartexamprep/models/question.dart';
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
      String email, String password, BuildContext context) async {
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
      debugPrint('Sign in error 1234: $e');
      String errorMessage = 'Error signing in. Please try again later.';
      ErrorResponse(errorCode: "Exception", errorMessage: errorMessage);
      if (e is FirebaseAuthException) {
        errorMessage = FirebaseAuthErrorMessages.getErrorMessage(e.code);
        errorResponse =
            ErrorResponse(errorCode: e.code, errorMessage: errorMessage);
      }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.toString()),
            // Ensure the error message is shown
            backgroundColor: Colors.red,
          ),
        );

      return FirebaseResponse(
          errorResponse: errorResponse,
          statusCode: ApiConstants.fail,
          statusMessage: ApiConstants.successMessage);
    }
  }

  signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      ErrorResponse errorResponse = ErrorResponse();
      if (kDebugMode) {
        print(e.toString());
      }
      debugPrint('Sign out error 123: $e');
      String errorMessage = 'Error signing out. Please try again later.';
      ErrorResponse(errorCode: "Exception", errorMessage: errorMessage);
      if (e is FirebaseAuthException) {
        errorMessage = FirebaseAuthErrorMessages.getErrorMessage(e.code);
        errorResponse =
            ErrorResponse(errorCode: e.code, errorMessage: errorMessage);
      }
      return errorResponse;
    }
  }

  Future<FirebaseResponse> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return FirebaseResponse(
          statusCode: ApiConstants.success,
          statusMessage: ApiConstants.successMessage);
    } catch (e) {
      ErrorResponse errorResponse = ErrorResponse();
      if (kDebugMode) {
        print(e.toString());
      }
      debugPrint('Sign in error 12345: $e');
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
    firebaseInstance.collection(Constants.userCollection);

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
        debugPrint('Account creation error: $errorMessage');
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

  Future<void> addQuizData(Map<String, dynamic> quizData, String quizId) async {
    await firebaseInstance
        .collection(Constants.quizCollection)
        .doc(quizId)
        .set(quizData)
        .catchError((e) {
      if (kDebugMode) {
        print(e.toString());
      }
    });
  }

  getQuizStream(bool userFlag, String quizTitle) {
    debugPrint(" getQuizStream $userFlag:: $quizTitle");
    if (userFlag) {
      return firebaseInstance
          .collection(Constants.quizCollection)
          .where('category', isEqualTo: quizTitle)
          .snapshots();
    } else {
      return firebaseInstance
          .collection(Constants.quizCollection)
          .where('isLive', isEqualTo: true)
          .where('category', isEqualTo: quizTitle)
          .snapshots();
    }
  }

  Future<void> saveOrUpdateQuestions(
      List<Questions> questionsList, String quizId) async {
    // Reference to the Firestore collection
    final collectionRef = firebaseInstance
        .collection(Constants.quizCollection)
        .doc(quizId)
        .collection(Constants.queAndAnsCollection);

    // Start a Firestore batch
    WriteBatch batch = firebaseInstance.batch();

    try {
      for (var question in questionsList) {
        // Check if the question has an ID
        if (question.id != null) {
          // Reference to the document with the given ID
          final docRef = collectionRef.doc(question.id);

          // Check if the document exists
          final docSnapshot = await docRef.get();
          if (docSnapshot.exists) {
            // Update existing document
            batch.update(docRef, question.toMap());
          } else {
            // Add new document with the given ID
            batch.set(docRef, question.toMap());
          }
        } else {
          // Create a new document with an auto-generated ID
          final newDocRef = collectionRef.doc();
          batch.set(newDocRef, question.toMap());
        }
      }

      // Commit the batch operation
      await batch.commit();
      debugPrint('Questions saved or updated successfully.');
    } catch (e) {
      debugPrint('Error saving or updating questions: $e');
    }
  }

  Future<List<Questions>> fetchQuestions(String documentId) async {
    // Reference to the Firestore collection
    final collectionRef = firebaseInstance
        .collection(Constants.quizCollection)
        .doc(documentId)
        .collection(Constants.queAndAnsCollection);

    try {
      // Fetch all documents in the collection
      final querySnapshot = await collectionRef.get();

      // Convert the documents into a list of Questions objects
      List<Questions> questionsList = querySnapshot.docs
          .map((doc) => Questions.fromMap(doc.data()))
          .toList();

      debugPrint('Questions fetched successfully.');
      return questionsList;
    } catch (e) {
      debugPrint('Error fetching questions: $e');
      return [];
    }
  }

  Future<void> deleteRecord(String quizId,String questionId) async {
    try {

      // Check if the document exists
      DocumentSnapshot docSnapshot = await firebaseInstance. collection(Constants.quizCollection)
        .doc(quizId)
        .collection(Constants.queAndAnsCollection).doc(questionId).get();

      if (docSnapshot.exists) {
        // If the document exists, delete it
        await firebaseInstance. collection(Constants.quizCollection)
            .doc(quizId)
            .collection(Constants.queAndAnsCollection).doc(questionId).delete();
        debugPrint('Document successfully deleted!');
      } else {
        // If the document doesn't exist
        debugPrint('Document with ID $questionId does not exist.');
      }
    } catch (e) {
      // Handle any errors that occur during the deletion process
      debugPrint('Error deleting document: $e');
    }
  }

}

final FirebaseService firebaseService = FirebaseService();
