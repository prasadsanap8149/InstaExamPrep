import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartexamprep/database/firebase_service.dart';
import 'package:smartexamprep/helper/helper_functions.dart';

import '../ad_service/widgets/banner_ad.dart';
import '../helper/app_colors.dart';
import '../helper/constants.dart';
import '../models/user_profile.dart';
import '../utils/validator_util.dart';
import '../widgets/custom_text_form_field.dart';

class CreateQuizType extends StatefulWidget {
  final UserProfile userProfile;
  final String quizTypeId;

  const CreateQuizType(
      {super.key, required this.userProfile, required this.quizTypeId});

  @override
  _CreateQuizTypeState createState() => _CreateQuizTypeState();
}

class _CreateQuizTypeState extends State<CreateQuizType> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _statusEditingController =
      TextEditingController();

  String? _editingDocId;

  Future<void> _addOrUpdateQuizType() async {
    if (_formKey.currentState!.validate()) {
      await firebaseService.saveOrUpdateQuizType(
        title: _titleEditingController.text,
        status: _statusEditingController.text == 'true' ? true : false,
        quizTypeId: _editingDocId ?? '', // use the doc ID if editing
        userId: widget.userProfile.id!,
      );

      // Clear the form
      _titleEditingController.clear();
      _statusEditingController.clear();
      _editingDocId = null; // reset to add mode
      setState(() {});
    }
  }

  void _deleteQuizType(String docId) async {
    final confirm = HelperFunctions.showCustomDialog(
        context, 'Confirm Delete', 'Are you sure to delete');
    if (confirm != true) return;
    await firebaseService.deleteQuizTypeRecord(docId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Type'),
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.accent,
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (Platform.isAndroid || Platform.isIOS) const GetBannerAd(),
                  const SizedBox(height: 5,),
                  buildTextField(
                    controller: _titleEditingController,
                    hintText: "Title",
                    icon: Icons.title,
                    validator: (value) => validatorService.validateName(
                      value: value!,
                      field: 'Title',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _statusEditingController.text.isEmpty
                        ? null
                        : _statusEditingController.text,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      prefixIcon: const Icon(
                        Icons.menu_open,
                        color: AppColors.fabIconColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'true', child: Text('Active')),
                      DropdownMenuItem(value: 'false', child: Text('Inactive')),
                    ],
                    onChanged: (value) {
                      _statusEditingController.text = value!;
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? "Please select status."
                        : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        _editingDocId == null ? Icons.add : Icons.save,
                        color: AppColors.fabIconColor,
                      ),
                      label: Text(
                        _editingDocId == null ? 'Add' : 'Update',
                        style: const TextStyle(color: AppColors.buttonText),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        backgroundColor: AppColors.fabBackground,
                      ),
                      onPressed: _addOrUpdateQuizType,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: firebaseService.getQuizTypeDetailsStream(
                    widget.userProfile.userRole == Constants.userRoles[0]
                        ? false
                        : true),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        child: ListTile(
                          title: Text(
                            doc['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: doc['status'] == true
                              ? const Text('Status: Active')
                              : const Text('Status: Inactive'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: AppColors.fabIconColor),
                                onPressed: () {
                                  setState(() {
                                    _editingDocId = doc.id;
                                    _titleEditingController.text = doc['title'];
                                    _statusEditingController.text =
                                        doc['status'].toString();
                                  });
                                },
                              ),
                              if (widget.userProfile.userRole.toString() !=
                                  Constants.userRoles[0])
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteQuizType(doc.id),
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
