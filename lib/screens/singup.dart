import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartexamprep/helper/api_constants.dart';
import 'package:smartexamprep/helper/constants.dart';
import 'package:smartexamprep/helper/local_storage.dart';
import 'package:smartexamprep/models/user_profile.dart';
import 'package:smartexamprep/screens/signin.dart';
import 'package:smartexamprep/services/user_service.dart';
import 'package:smartexamprep/utils/validator_util.dart';
import 'package:smartexamprep/widgets/custom_text_form_field.dart';

import '../database/firebase_service.dart';
import '../helper/app_colors.dart';
import '../helper/helper_functions.dart';
import '../models/response.dart';
import '../widgets/app_bar.dart';
import 'home_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  Set<String> selectedTopics = {};
  final TextEditingController nameTextEditingController =
      TextEditingController();
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController mobileTextEditingController =
      TextEditingController();
  final TextEditingController preferredLanguageController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();
  final TextEditingController rePasswordTextEditingController =
      TextEditingController();
  final TextEditingController preferredLanguageEditingController =
      TextEditingController();
  final TextEditingController genderEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  //Clearing memory cache
  @override
  void dispose() {
    super.dispose();
    nameTextEditingController.dispose();
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
    mobileTextEditingController.dispose();
    rePasswordTextEditingController.dispose();
    preferredLanguageController.dispose();
    genderEditingController.dispose();
  }

  bool isLoading = false;
  bool passwordVisible = true;

  void _toggleInterest(String topics) {
    setState(() {
      if (selectedTopics.contains(topics)) {
        selectedTopics.remove(topics);
      } else {
        selectedTopics.add(topics);
        debugPrint(selectedTopics.toString());
      }
    });
  }

  signUp() async {
    //Validate the form
    if (_formKey.currentState!.validate()) {
      if (passwordTextEditingController.text
              .compareTo(rePasswordTextEditingController.text) <
          0) {
        HelperFunctions.showSnackBarMessage(
            context: context,
            message: "Password not matched!",
            color: Colors.red);
        return;
      }
      if (validatorService.validateNumber(
              value: mobileTextEditingController.text) !=
          null) {
        HelperFunctions.showSnackBarMessage(
            context: context,
            message: "Please enter valid mobile number",
            color: Colors.red);
        return;
      }
      setState(() {
        isLoading = true;
      });
      //Save user details
      try {
        UserProfile userProfile = UserProfile(
          name: nameTextEditingController.text.trim(),
          email: emailTextEditingController.text.trim(),
          selectedTopics: selectedTopics,
          preferredLanguage: preferredLanguageController.text.trim(),
          mobile: mobileTextEditingController.text.trim(),
          createdOn: DateTime.timestamp(),
          userRole: Constants.userRoles[0],
          gender: genderEditingController.text.trim() ?? "Other",
        );
        Response response = await userService.createNewUser(
            emailTextEditingController.text.trim(),
            passwordTextEditingController.text.trim(),
            userProfile);
        debugPrint("Response ::${response.toString()}");
        if (response.statusCode == ApiConstants.success) {
          var user = await firebaseService.signInEmailAndPass(
              emailTextEditingController.text.trim(),
              passwordTextEditingController.text.trim(),
              context);

          if (user != null) {
            if (kDebugMode) {
              print('Sign up user details:${user.userResponse.toString()}');
            }
            UserProfile userProfile = await firebaseService.getUserDetails(
                userId: user.userResponse!.uid);
            await LocalStorage.saveUserLoggedInDetails(
                isLoggedIn: true,
                userId: userProfile.id!,
                userProfile: userProfile);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(userProfile: userProfile)),
            );
          }
        }
        if (response.statusCode == ApiConstants.fail) {
          HelperFunctions.showSnackBarMessage(
              context: context,
              message: response.message,
              color: Colors.redAccent);
        }
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        if (kDebugMode) {
          print("Exception::${e.toString()}");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: const GetBannerAd(),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: appBar(context),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          "Welcome Aboard!",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildTextField(
                        controller: nameTextEditingController,
                        hintText: "Name",
                        icon: Icons.person,
                        validator: (value) => validatorService.validateName(
                            value: value!, field: 'Name'),
                      ),
                      const SizedBox(height: 16),
                      buildTextField(
                        controller: emailTextEditingController,
                        hintText: "Email",
                        icon: Icons.email,
                        validator: validatorService.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      buildTextField(
                        controller: mobileTextEditingController,
                        hintText: "Mobile",
                        icon: Icons.call,
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            validatorService.validateNumber(value: value!),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: preferredLanguageController.text.isEmpty
                            ? null
                            : preferredLanguageController.text,
                        decoration: InputDecoration(
                          labelText: 'Language',
                          prefixIcon: const Icon(Icons.language,
                              color: AppColors.fabIconColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ['English', 'Marathi', 'Hindi']
                            .map((language) => DropdownMenuItem(
                                  value: language,
                                  child: Text(language),
                                ))
                            .toList(),
                        onChanged: (value) {
                          preferredLanguageController.text = value!;
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? "Please select a language."
                            : null,
                      ),

                      const SizedBox(height: 16),
                      buildTextField(
                        controller: passwordTextEditingController,
                        hintText: "Password",
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (value) => value!.isEmpty
                            ? Constants.passwordMessage
                            : value.length < 6
                                ? Constants.passwordLengthMessage
                                : null,
                      ),
                      const SizedBox(height: 16),
                      buildTextField(
                        controller: rePasswordTextEditingController,
                        hintText: "Re-Password",
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
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: genderEditingController.text.isEmpty
                            ? null
                            : genderEditingController.text,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: const Icon(Icons.person,
                              color: AppColors.fabIconColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ['Male', 'Female', 'Other']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          genderEditingController.text = value!;
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? "Please select your gender."
                            : null,
                      ),

                      //_buildGenderSelector(),
                      //_buildInterestSection(),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: signUp,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: AppColors.buttonBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                              fontSize: 16, color: AppColors.buttonText),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?",
                              style: TextStyle(fontSize: 15.5)),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SignIn()),
                              );
                            },
                            child: Text(
                              "Sign In",
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

      /*   body: isLoading
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
                    SizedBox(
                      height: 310,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            TextFormField(
                              keyboardType: TextInputType.visiblePassword,
                              style: const TextStyle(
                                color: AppColors.accent,
                              ),
                              validator: (value) {
                                return validatorService.validateName(
                                    value: value!, field: 'Name');
                              },
                              controller: nameTextEditingController,
                              decoration: const InputDecoration(
                                hintText: "Name",
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: AppColors.fabIconColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: heightValue,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.visiblePassword,
                              style: const TextStyle(
                                color: AppColors.accent,
                              ),
                              validator: (value) {
                                return validatorService.validateEmail(value);
                              },
                              decoration: const InputDecoration(
                                hintText: "Email",
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: AppColors.fabIconColor,
                                ),
                              ),
                              controller: emailTextEditingController,
                            ),
                            SizedBox(
                              height: heightValue,
                            ),
                            TextFormField(
                              validator: (value) {
                                return validatorService.validateNumber(
                                    value: value!);
                              },
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: AppColors.accent,
                              ),
                              decoration: const InputDecoration(
                                hintText: "Mobile",
                                prefixIcon: Icon(
                                  Icons.call,
                                  color: AppColors.fabIconColor,
                                ),
                              ),
                              controller: mobileTextEditingController,
                            ),
                            SizedBox(
                              height: heightValue,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter language.";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: AppColors.accent,
                              ),
                              decoration: const InputDecoration(
                                hintText: "Language",
                                prefixIcon: Icon(
                                  Icons.language,
                                  color: AppColors.fabIconColor,
                                ),
                              ),
                              controller: preferredLanguageController,
                            ),
                            SizedBox(
                              height: heightValue,
                            ),
                            TextFormField(
                              obscureText: true,
                              style: const TextStyle(
                                color: AppColors.accent,
                              ),
                              validator: (value) {
                                return value!.isEmpty
                                    ? Constants.passwordMessage
                                    : value.length < 6
                                        ? Constants.passwordLengthMessage
                                        : null;
                              },
                              decoration: const InputDecoration(
                                hintText: "Password",
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: AppColors.fabIconColor,
                                ),
                              ),
                              controller: passwordTextEditingController,
                            ),
                            SizedBox(
                              height: heightValue,
                            ),
                            TextFormField(
                              obscureText: passwordVisible,
                              style: const TextStyle(
                                color: AppColors.accent,
                              ),
                              validator: (value) {
                                return value!.isEmpty
                                    ? Constants.passwordMessage
                                    : value.length < 6
                                        ? Constants.passwordLengthMessage
                                        : null;
                              },
                              decoration: InputDecoration(
                                hintText: "Re-Password",
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: AppColors.fabIconColor,
                                ),
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
                              controller: rePasswordTextEditingController,
                            ),
                            const Text(
                              'Select Gender',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio<String>(
                                  value: 'Male',
                                  groupValue: _selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value!;
                                    });
                                  },
                                ),
                                const Text('Male'),
                                Radio<String>(
                                  value: 'Female',
                                  groupValue: _selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value!;
                                    });
                                  },
                                ),
                                const Text('Female'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Select your quiz interest',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Wrap(
                              spacing: 8.0,
                              children: Constants.topicNames.map((interest) {
                                return ChoiceChip(
                                  label: Text(interest),
                                  selected: selectedTopics.contains(interest),
                                  onSelected: (selected) {
                                    _toggleInterest(interest);
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: isLoading ? null : signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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
                                      "Sign Up",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.buttonText,
                                      ),
                                    ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Already have an account?",
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
                                            builder: (context) =>
                                                const SignIn()));
                                  },
                                  child: const Text(
                                    "Sign in",
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),*/
    );
  }

/* Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Gender',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: genders.map((gender) {
            return Row(
              children: [
                Radio<String>(
                  value: gender,
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() => _selectedGender = value!);
                  },
                ),
                Text(gender),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
*/
/*  Widget _buildInterestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select your quiz interest',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: Constants.topicNames.map((topic) {
            final isSelected = selectedTopics.contains(topic);
            return FilterChip(
              label: Text(topic),
              selected: isSelected,
              onSelected: (_) => _toggleInterest(topic),
            );
          }).toList(),
        ),
      ],
    );
  }*/
}
