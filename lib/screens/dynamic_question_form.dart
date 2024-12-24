import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartexamprep/helper/constants.dart';
import 'package:smartexamprep/models/quiz.dart';

import '../widgets/app_bar.dart';

class DynamicQuestionForm extends StatefulWidget {
  final String userId;
  final Quiz quiz;

  const DynamicQuestionForm(
      {super.key, required this.userId, required this.quiz});

  @override
  State<DynamicQuestionForm> createState() => _DynamicQuestionFormState();
}

class _DynamicQuestionFormState extends State<DynamicQuestionForm> {
  String selectedLanguage = "English";
  Set<String> addedLanguagesSet= <String>{};
  final Map<String, TextEditingController> _controllers = {};


  void _addLanguage() {
    if (!addedLanguagesSet.contains(selectedLanguage)) {
      setState(() {
        addedLanguagesSet.add(selectedLanguage);
        _controllers['${selectedLanguage}_question'] = TextEditingController();
        _controllers['${selectedLanguage}_option1'] = TextEditingController();
        _controllers['${selectedLanguage}_option2'] = TextEditingController();
        _controllers['${selectedLanguage}_option3'] = TextEditingController();
        _controllers['${selectedLanguage}_option4'] = TextEditingController();
        _controllers['${selectedLanguage}_answer'] = TextEditingController();
        _controllers['${selectedLanguage}_description'] =
            TextEditingController();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select other language option of question'),
          backgroundColor: Colors.red,
        ),
      );
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
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            Text(
              widget.quiz.title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(
              height: 10,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Language',
                border: OutlineInputBorder(),
              ),
              value: selectedLanguage,
              items: Constants.availableLanguages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
            ),
            // Form(
            //   key: _formKey,
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //
            //       Column(
            //         children: addedLanguages.map((lang) {
            //           return Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Row(
            //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                 children: [
            //                   Text('Language: $lang',
            //                       style: const TextStyle(
            //                           fontSize: 16,
            //                           fontWeight: FontWeight.bold)),
            //                   ElevatedButton(
            //                     onPressed: () {
            //                       addedLanguages.remove(lang);
            //                       setState(() {});
            //                     },
            //                     child: const Icon(
            //                       Icons.delete,
            //                       color: Colors.red,
            //                     ),
            //                   )
            //                 ],
            //               ),
            //               TextFormField(
            //                 controller: _controllers['${lang}_question'],
            //                 decoration:
            //                 InputDecoration(labelText: 'Question ($lang)'),
            //                 validator: (value) {
            //                   if (value!.isEmpty) {
            //                     return 'Please enter a question in $lang';
            //                   }
            //                   return null;
            //                 },
            //               ),
            //               TextFormField(
            //                 controller: _controllers['${lang}_option1'],
            //                 decoration:
            //                 InputDecoration(labelText: 'Option 1 ($lang)'),
            //                 validator: (value) {
            //                   if (value!.isEmpty) {
            //                     return 'Please enter Option 1 in $lang';
            //                   }
            //                   return null;
            //                 },
            //               ),
            //               TextFormField(
            //                 controller: _controllers['${lang}_option2'],
            //                 decoration:
            //                 InputDecoration(labelText: 'Option 2 ($lang)'),
            //                 validator: (value) {
            //                   if (value!.isEmpty) {
            //                     return 'Please enter Option 2 in $lang';
            //                   }
            //                   return null;
            //                 },
            //               ),
            //               TextFormField(
            //                 controller: _controllers['${lang}_option3'],
            //                 decoration:
            //                 InputDecoration(labelText: 'Option 3 ($lang)'),
            //                 validator: (value) {
            //                   if (value!.isEmpty) {
            //                     return 'Please enter Option 3 in $lang';
            //                   }
            //                   return null;
            //                 },
            //               ),
            //               TextFormField(
            //                 controller: _controllers['${lang}_option4'],
            //                 decoration:
            //                 InputDecoration(labelText: 'Option 4 ($lang)'),
            //                 validator: (value) {
            //                   if (value!.isEmpty) {
            //                     return 'Please enter Option 4 in $lang';
            //                   }
            //                   return null;
            //                 },
            //               ),
            //               DropdownButtonFormField<String>(
            //                 decoration: const InputDecoration(
            //                     labelText: 'Correct Option'),
            //                 items: List.generate(
            //                     4, (index) => 'Option ${index + 1}')
            //                     .map((String value) {
            //                   return DropdownMenuItem<String>(
            //                     value: value,
            //                     child: Text(value),
            //                   );
            //                 }).toList(),
            //                 onChanged: (value) {
            //                   setState(() {
            //                     if (value == "Option 1") {
            //                       _controllers['${lang}_answer']?.text =
            //                           _controllers['${lang}_option1']!.text;
            //                     } else if (value == "Option 2") {
            //                       _controllers['${lang}_answer']?.text =
            //                           _controllers['${lang}_option2']!.text;
            //                     } else if (value == "Option 3") {
            //                       _controllers['${lang}_answer']?.text =
            //                           _controllers['${lang}_option3']!.text;
            //                     } else if (value == "Option 4") {
            //                       _controllers['${lang}_answer']?.text =
            //                           _controllers['${lang}_option4']!.text;
            //                     }
            //                   });
            //                 },
            //                 validator: (value) {
            //                   if (value == null) {
            //                     return 'Please select the correct option';
            //                   }
            //                   return null;
            //                 },
            //               ),
            //               TextFormField(
            //                 controller: _controllers['${lang}_description'],
            //                 decoration: InputDecoration(
            //                     labelText: 'Description ($lang)'),
            //                 validator: (value) {
            //                   if (value!.isEmpty) {
            //                     return 'Please enter description in $lang';
            //                   }
            //                   return null;
            //                 },
            //               ),
            //               const SizedBox(height: 20),
            //             ],
            //           );
            //         }).toList(),
            //       ),
            //       const SizedBox(
            //         height: 15,
            //       ),
            //       DropdownButtonFormField<String>(
            //         decoration: const InputDecoration(
            //           labelText: 'Add Language',
            //           border: OutlineInputBorder(),
            //         ),
            //         value: selectedLanguage,
            //         items: availableLanguages.map((lang) {
            //           return DropdownMenuItem<String>(
            //             value: lang,
            //             child: Text(lang),
            //           );
            //         }).toList(),
            //         onChanged: (value) {
            //           setState(() {
            //             selectedLanguage = value!;
            //           });
            //         },
            //       ),
            //       const SizedBox(height: 20),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
