import 'package:flutter/material.dart';

Widget appBar(BuildContext context) {
  return RichText(
    text: const TextSpan(
      style: TextStyle(fontSize: 22),
      children: <TextSpan>[
        TextSpan(
            text: 'Smart',
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            )),
        TextSpan(
            text: 'Exam',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        TextSpan(
            text: 'Prep',
            style: TextStyle(
                color: Colors.greenAccent, fontWeight: FontWeight.bold))
      ],
    ),
  );
}