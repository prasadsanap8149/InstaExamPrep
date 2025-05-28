import 'package:flutter/material.dart';

Widget appBar(BuildContext context) {
  return RichText(
    text: TextSpan(
      style: const TextStyle(fontSize: 22),
      children: <TextSpan>[
        TextSpan(
            text: 'Smart',
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.bold,
            )),
        TextSpan(
            text: 'Exam',
            style: TextStyle(
                color: Colors.yellow[800], fontWeight: FontWeight.bold)),
        TextSpan(
            text: 'Prep',
            style:
                TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold))
      ],
    ),
  );
}
