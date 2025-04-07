import 'package:flutter/foundation.dart';
import 'package:smartexamprep/database/firebase_service.dart';
import 'package:smartexamprep/helper/constants.dart';
import 'package:smartexamprep/models/firebase_response.dart';
import 'package:smartexamprep/models/response.dart';
import 'package:smartexamprep/models/user_profile.dart';

import '../helper/api_constants.dart';

class UserService {
  Future<Response> createNewUser(
      String email, String password, UserProfile userProfile) async {
    FirebaseResponse? firebaseResponse =
        await firebaseService.signUpWithEmailAndPassword(email, password);
    if (kDebugMode) {
      print(
          "Data received signUpWithEmailAndPassword::${firebaseResponse.toString()}");
    }
    if (firebaseResponse?.statusCode == ApiConstants.success) {
      UserProfile localUserProfile = UserProfile(
        id: firebaseResponse?.userResponse?.uid,
        name: userProfile.name,
        email: userProfile.email,
        selectedTopics: userProfile.selectedTopics,
        preferredLanguage: userProfile.preferredLanguage,
        mobile: userProfile.mobile,
        createdOn: userProfile.createdOn,
        userRole: Constants.userRoles[0],
        gender: userProfile.gender
      );
      if (kDebugMode) {
        print("Data ::${localUserProfile.toString()}");
      }

      var firebaseResponse2 = await firebaseService.saveUserProfile(userProfile: localUserProfile);
      if(firebaseResponse2.statusCode==ApiConstants.success) {
        return Response(
            statusCode: ApiConstants.success,
            message: Constants.accountCreated);
      }else{
        return Response(
            statusCode: ApiConstants.fail,
            message: Constants.accountNotCreated);
      }
    }
    if (firebaseResponse?.statusCode == ApiConstants.fail) {
      return Response(
          statusCode: firebaseResponse!.statusCode,
          message: firebaseResponse.errorResponse!.errorMessage!);
    }

    return Response(
        statusCode: ApiConstants.fail, message: Constants.serviceError);
  }
}

final UserService userService = UserService();
