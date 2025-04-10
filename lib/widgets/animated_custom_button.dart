import 'package:flutter/material.dart';

import '../helper/app_colors.dart';

class AnimatedCustomButton extends StatefulWidget {
  final String btnLabel;
  final double? btnWidth;
  final Color btnColor;
  final VoidCallback onTap;

  const AnimatedCustomButton({
    super.key,
    required this.btnLabel,
    required this.btnColor,
    required this.onTap,
    this.btnWidth,
  });

  @override
  _AnimatedCustomButtonState createState() => _AnimatedCustomButtonState();
}

class _AnimatedCustomButtonState extends State<AnimatedCustomButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: widget.btnWidth ?? MediaQuery.of(context).size.width * 0.949,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: widget.btnColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 4),
              )
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.btnLabel,
            style: const TextStyle(
              color: AppColors.buttonText,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
