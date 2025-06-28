import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'add_set.dart' as add_set; // For SavedTimerSet
import 'main_page.dart'; // For TimerSetListPage
import 'timer_history.dart' as history;
import 'package:shared_preferences/shared_preferences.dart';

class TimerSetScreen extends StatefulWidget {
  final add_set.SavedTimerSet timerSet;
  const TimerSetScreen({super.key, required this.timerSet});

  @override
  State<TimerSetScreen> createState() => _TimerSetScreenState();
}

class _TimerSetScreenState extends State<TimerSetScreen>
    with SingleTickerProviderStateMixin {
  late List<int> _secondsList;
  int _currentStage = 0;
  int _remaining = 0;
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;

  late AnimationController _animationController;
  bool _pointsGiven = false;
  bool _showFinished = false;

  @override
  void initState() {
    super.initState();
    _secondsList = List.from(widget.timerSet.secondsList);
    _remaining = _secondsList[0];
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _remaining > 0 ? _remaining : 1),
    );
  }

  void _startOrPauseOrResumeTimer() {
    if (!_isRunning && !_isPaused) {
      _startTimer();
    } else if (_isRunning && !_isPaused) {
      _pauseTimer();
    } else if (_isPaused) {
      _resumeTimer();
    }
  }

  void _startTimer() {
    if (_timer != null) _timer!.cancel();
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _pointsGiven = false;
      _showFinished = false;
    });
    _animationController.duration = Duration(
      seconds: _remaining > 0 ? _remaining : 1,
    );
    _animationController.reverse(from: 1.0);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining > 0) {
        setState(() {
          _remaining--;
        });
      } else {
        if (_currentStage < _secondsList.length - 1) {
          setState(() {
            _currentStage++;
            _remaining = _secondsList[_currentStage];
            _animationController.duration = Duration(
              seconds: _remaining > 0 ? _remaining : 1,
            );
            _animationController.reverse(from: 1.0);
          });
        } else {
          timer.cancel();
          setState(() {
            _isRunning = false;
            _isPaused = false;
            _showFinished = true;
          });
          _animationController.stop();
          _givePointsAndPop();
        }
      }
    });
  }

  void _resetTimer() {
    if (_timer != null) _timer!.cancel();
    setState(() {
      _currentStage = 0;
      _remaining = _secondsList[0];
      _isRunning = false;
      _isPaused = false;
      _pointsGiven = false;
      _showFinished = false;
    });
    _animationController.duration = Duration(
      seconds: _remaining > 0 ? _remaining : 1,
    );
    _animationController.value = 1.0;
  }

  void _pauseTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      setState(() {
        _isPaused = true;
        _isRunning = false;
      });
      _animationController.stop();
    }
  }

  void _resumeTimer() {
    if (_isPaused) {
      setState(() {
        _isPaused = false;
        _isRunning = true;
      });
      _animationController.reverse(from: _animationController.value);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remaining > 0) {
          setState(() {
            _remaining--;
          });
        } else {
          if (_currentStage < _secondsList.length - 1) {
            setState(() {
              _currentStage++;
              _remaining = _secondsList[_currentStage];
              _animationController.duration = Duration(
                seconds: _remaining > 0 ? _remaining : 1,
              );
              _animationController.reverse(from: 1.0);
            });
          } else {
            timer.cancel();
            setState(() {
              _isRunning = false;
              _isPaused = false;
              _showFinished = true;
            });
            _animationController.stop();
            _givePointsAndPop();
          }
        }
      });
    }
  }

  void _givePointsAndPop() async {
    if (_pointsGiven) return;
    setState(() {
      _pointsGiven = true;
    });
    int points = _secondsList.fold(0, (a, b) => a + b);
    final entry = history.TimerSetHistoryEntry(
      name: widget.timerSet.name,
      completedAt: DateTime.now(),
      totalSeconds: points,
    );
    await history.saveHistoryEntry(entry);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const TimerSetListPage()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool finished =
        !_isRunning &&
        _currentStage == _secondsList.length - 1 &&
        _remaining == 0;
    return Scaffold(
      appBar: AppBar(title: Text(widget.timerSet.name)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Text(
                'Stage ${_currentStage + 1} / ${_secondsList.length}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: finished ? null : _startOrPauseOrResumeTimer,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: TimerPainter(
                        animation: _animationController,
                        backgroundColor: Colors.grey.shade300,
                        color: _isPaused ? Colors.orange : Colors.deepOrange,
                      ),
                      child: Container(
                        width: 320,
                        height: 320,
                        alignment: Alignment.center,
                        child: Text(
                          '$_remaining',
                          style: Theme.of(
                            context,
                          ).textTheme.displayLarge?.copyWith(fontSize: 140),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 24,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: (_isRunning || _isPaused || finished)
                        ? _resetTimer
                        : null,
                    child: const Text('Reset'),
                  ),
                ],
              ),
              if (finished && _showFinished)
                const Padding(
                  padding: EdgeInsets.only(top: 24.0),
                  child: Text(
                    'All stages finished!\nPoints will be added automatically.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              if (_isPaused)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Paused (tap timer to resume)',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              if (!_isRunning && !_isPaused && !finished)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Tap timer to start',
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ),
              if (_isRunning && !_isPaused)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Tap timer to pause',
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  TimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 22.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint progressPaint = Paint()
      ..color = color
      ..strokeWidth = 22.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 22;

    // Draw background circle
    canvas.drawCircle(center, radius, paint);

    // Draw progress arc
    double progress = (1.0 - animation.value) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
