import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartexamprep/models/user_profile.dart';
import 'package:smartexamprep/utils/utils.dart';

import '../helper/constants.dart';
import '../helper/helper_functions.dart';
import '../widgets/app_bar.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile profileDetails;
  const ProfileScreen({super.key, required this.profileDetails});

  @override
  State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  late List<String> interests;
  bool buttonFlag=false;

  @override
  void initState() {
    super.initState();
    interests = widget.profileDetails.selectedTopics.toList();
    setState(() {

    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '(^^)';

    // Split the name by spaces
    List<String> nameParts = name.trim().split(' ');

    // Take the first letter of each part and join them
    String initials = nameParts.map((part) => part[0]).join();

    return initials.toUpperCase();
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (interests.contains(interest)) {
        if (interests.length > 1) {
          interests.remove(interest);
        } else {
          HelperFunctions.showSnackBarMessage(
              context: context,
              message: 'At least one interest must be selected.',
              color: Colors.orangeAccent);
        }
      } else {
        interests.add(interest);
      }
    });
  }

  _submitProfileInterestChanges() async {
    if(buttonFlag) {
      if (interests.length > 1) {

        bool isSuccess = true;/*await firebaseService.updateUserProfileInterest(
            userId: widget.userId, interests: interests);*/
        if (isSuccess) {
          HelperFunctions.showSnackBarMessage(context: context,
              message: "Interest updated successfully!!",
              color: Colors.greenAccent);
        } else {
          HelperFunctions.showSnackBarMessage(context: context,
              message: "Interest not updated!!",
              color: Colors.redAccent);
        }
      } else {
        HelperFunctions.showSnackBarMessage(
            context: context,
            message: 'At least one interest must be selected.',
            color: Colors.redAccent);
      }
    }else{
      HelperFunctions.showSnackBarMessage(context: context,
          message: "You have not made any changes!",
          color: Colors.orangeAccent);
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.greenAccent, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.amber,
                    child: Text(
                      _getInitials(widget.profileDetails.name.toString()),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildProfileInfoRow(Icons.email, 'Email:',
                    widget.profileDetails.email.toString()),
                _buildProfileInfoRow(Icons.person, 'Name:',
                    widget.profileDetails.name.toString()),
                _buildProfileInfoRow(Icons.phone, 'Mobile:',
                    widget.profileDetails.mobile.toString()),
                _buildProfileInfoRow(Icons.account_box, 'Role:',
                    widget.profileDetails.userRole.toString()),
                _buildProfileInfoRow(Icons.calendar_today, 'Joined:',
                    utils.formatDateTime(widget.profileDetails.createdOn)),
                const SizedBox(height: 20),
                const Text(
                  'Topics:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    Wrap(
                      spacing: 3.0,
                      children: Constants.topicNames
                          .map((interest) => ChoiceChip(
                        label: Text(interest),
                        selected: interests.contains(interest),
                        selectedColor: Colors.greenAccent,
                        backgroundColor: Colors.amberAccent,
                        onSelected: (selected) {
                          _toggleInterest(interest);
                          buttonFlag=true;
                        },
                        labelStyle: TextStyle(
                          color:
                          Constants.topicNames.contains(interest)
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                          .toList(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent.shade400,
                      ),

                      onPressed: _submitProfileInterestChanges,
                      child: const Text('Update Changes'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.amberAccent),
          const SizedBox(width: 10),
          Text(
            '$label ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.amberAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
