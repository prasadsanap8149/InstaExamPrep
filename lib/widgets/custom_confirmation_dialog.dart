import 'package:flutter/material.dart';

// Reusable confirmation dialog widget
class CustomConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmButtonText;
  final String cancelButtonText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CustomConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmButtonText,
    required this.cancelButtonText,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            onCancel();
            Navigator.of(context).pop();
          },
          child: Text(cancelButtonText),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: Text(confirmButtonText),
        ),
      ],
    );
  }
}
