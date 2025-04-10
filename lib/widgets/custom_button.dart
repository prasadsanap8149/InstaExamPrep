import "package:flutter/material.dart";
import "package:smartexamprep/helper/app_colors.dart";

Widget customButton(
    {required BuildContext context,
      required String btnLabel,
      btnWidth,
      btnColor}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 18),
    decoration: BoxDecoration(
      color: btnColor,
      borderRadius: BorderRadius.circular(30),
    ),
    alignment: Alignment.center,
    width: btnWidth ?? MediaQuery.of(context).size.width * 0.949,
    child: Text(
      btnLabel,
      style: const TextStyle(
        color: AppColors.buttonText,
        fontSize: 15,
      ),
    ),
  );
}