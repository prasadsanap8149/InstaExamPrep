import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartexamprep/models/auth_response.dart';
import 'package:smartexamprep/models/error_response.dart';

class FirebaseResponse{
    final User? userResponse;
    final ErrorResponse? errorResponse;
    final int statusCode;
    final String statusMessage;
    FirebaseResponse({required this.statusCode,required this.statusMessage, this.errorResponse,this.userResponse});
}