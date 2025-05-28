import 'package:flutter/material.dart';

import '../helper/app_colors.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  Widget? suffixIcon,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    style: const TextStyle(color: AppColors.accent),
    validator: validator,
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: AppColors.fabIconColor),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
