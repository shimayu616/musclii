import 'package:flutter/material.dart';
import 'dart:async';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _seconds = 0;
  Timer? _timer;
  bool _isRunning = false;

  void _startTimer() {
    if (_isRunning) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
    setState(() {
      _isRunning = true;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _isRunning = false;
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メインページ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ようこそ！筋トレアプリのメインページです。',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 40),
            Text(
              _formatTime(_seconds),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startTimer,
                  child: const Text('スタート'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _stopTimer,
                  child: const Text('ストップ'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text('リセット'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}