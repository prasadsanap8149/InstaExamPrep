import 'dart:async';
import 'package:flutter/material.dart';

class CompactCountdownTimer extends StatefulWidget {
  final Duration duration;

  const CompactCountdownTimer({super.key, required this.duration});

  @override
  State<CompactCountdownTimer> createState() => _CompactCountdownTimerState();
}

class _CompactCountdownTimerState extends State<CompactCountdownTimer> {
  late Duration _remainingTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _remainingTime -= const Duration(seconds: 1);
        if (_remainingTime.inSeconds <= 0) {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final hours = _remainingTime.inHours.toString().padLeft(2, '0');
    final minutes = _remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.timer, size: 18, color: Colors.redAccent),
        const SizedBox(width: 4),
        Text(
          _formattedTime,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }
}
