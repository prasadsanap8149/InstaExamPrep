import 'package:flutter/material.dart';
import 'package:smartexamprep/models/user_profile.dart';

class ExamsHome extends StatelessWidget {
  final UserProfile? userProfile;
  const ExamsHome({super.key,  this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: Text(userProfile.toString()),
    );
  }
}
