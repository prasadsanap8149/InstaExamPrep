import 'dart:async';

import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final Duration duration;

  const CountdownTimer({super.key, required this.duration});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration _remainingTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = _remainingTime - const Duration(seconds: 1);
        if (_remainingTime.inSeconds <= 0) {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String Function(int n) get _twoDigits {
    return (int n) => n.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final days = _twoDigits(_remainingTime.inDays);
    final hours = _twoDigits(_remainingTime.inHours.remainder(24));
    final minutes = _twoDigits(_remainingTime.inMinutes.remainder(60));
    final seconds = _twoDigits(_remainingTime.inSeconds.remainder(60));

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.greenAccent),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          const Text(
            'TIME LEFT',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,wordSpacing: 10, letterSpacing: 15,),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeCard(hours, 'h'),
              const Text(':',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900),),
              _buildTimeCard(minutes, 'm'),
              const Text(':',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900),),
              _buildTimeCard(seconds, 's'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(String time, String unit) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.pink.shade300,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Row(
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 5,),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        // SizedBox(height: 2.0),
        // Text(unit, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
      ],
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title:  const Text('Countdown Timer')),
        body: const Center(
          child: CountdownTimer(
            duration: Duration(days: 0, hours: 5, minutes: 23, seconds: 40),
          ),
        ),
      ),
    );
  }
}
