import 'package:flutter/material.dart';

class MultipleChoiceQuestion extends StatefulWidget {
    final int totalOption;
   const MultipleChoiceQuestion({super.key, required this.totalOption});

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  final _multipleChoiceQuestion = GlobalKey<FormState>();
  final _questionContent =TextEditingController();

  final _option =TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _multipleChoiceQuestion,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          children: [
            const Text(
              "Quiz Description",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            TextFormField(
              controller: _questionContent,
              maxLines: 5,
              // Adjust as needed
              minLines: 3,
              // Minimum height of the text area
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter quiz description.',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blue, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey, width: 1.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.red, width: 1.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.red, width: 2.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description cannot be empty';
                }
                return null;
              },
            ),


          ],
        ),
      ),
    );
  }
}
