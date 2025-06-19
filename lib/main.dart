import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class SavedTimerSet {
  String name;
  List<int> secondsList;
  SavedTimerSet({required this.name, required this.secondsList});
}

class TimerSetHistoryEntry {
  final String name;
  final DateTime completedAt;
  final int totalSeconds;
  TimerSetHistoryEntry({
    required this.name,
    required this.completedAt,
    required this.totalSeconds,
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saved Timer Sets',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const TimerSetListPage(),
    );
  }
}

class TimerSetListPage extends StatefulWidget {
  const TimerSetListPage({super.key});
  @override
  State<TimerSetListPage> createState() => _TimerSetListPageState();
}

class _TimerSetListPageState extends State<TimerSetListPage> {
  final List<SavedTimerSet> _timerSets = [];
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _secondsControllers = [
    TextEditingController(),
  ];
  int _totalPoints = 0;
  final List<TimerSetHistoryEntry> _history = [];

  void _addSecondsField() {
    setState(() {
      _secondsControllers.add(TextEditingController());
    });
  }

  void _removeSecondsField(int index) {
    if (_secondsControllers.length > 1) {
      setState(() {
        _secondsControllers[index].dispose();
        _secondsControllers.removeAt(index);
      });
    }
  }

  void _addTimerSet() {
    final name = _nameController.text.trim();
    final secondsList = _secondsControllers
        .map((c) => int.tryParse(c.text) ?? 0)
        .where((s) => s > 0)
        .toList();
    if (name.isNotEmpty && secondsList.isNotEmpty) {
      setState(() {
        _timerSets.add(SavedTimerSet(name: name, secondsList: secondsList));
        _nameController.clear();
        for (final c in _secondsControllers) {
          c.clear();
        }
      });
    }
  }

  void _removeTimerSet(int index) {
    setState(() {
      _timerSets.removeAt(index);
    });
  }

  void _editTimerSet(int index) async {
    final edited = await showDialog<SavedTimerSet>(
      context: context,
      builder: (context) => EditTimerSetDialog(timerSet: _timerSets[index]),
    );
    if (edited != null) {
      setState(() {
        _timerSets[index] = edited;
      });
    }
  }

  void _goToTimerScreen(SavedTimerSet timerSet) async {
    final TimerSetHistoryEntry? historyEntry = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimerSetScreen(timerSet: timerSet),
      ),
    );
    if (historyEntry != null) {
      setState(() {
        _totalPoints += historyEntry.totalSeconds;
        _history.insert(0, historyEntry);
        if (_history.length > 5) {
          _history.removeLast();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You earned ${historyEntry.totalSeconds} points! Total: $_totalPoints',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _secondsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Timer Sets'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '$_totalPoints',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: SavedSetsHeader(
              minExtent: 320,
              maxExtent: 340,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Set Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _addTimerSet,
                          child: const Text('Add Set'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _secondsControllers.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              SizedBox(
                                width: 90,
                                child: TextField(
                                  controller: _secondsControllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Sec ${index + 1}',
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeSecondsField(index),
                              ),
                              const SizedBox(width: 4),
                            ],
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _addSecondsField,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Seconds'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: 8,
              ),
              child: const Text(
                'Saved Sets',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
          _timerSets.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: const Center(child: Text('No timer sets saved.')),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final timerSet = _timerSets[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 2,
                      ),
                      child: Card(
                        child: ListTile(
                          title: Text(
                            '${timerSet.name} (${timerSet.secondsList.join(", ")}s)',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _editTimerSet(index),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeTimerSet(index),
                              ),
                            ],
                          ),
                          onTap: () => _goToTimerScreen(timerSet),
                        ),
                      ),
                    );
                  }, childCount: _timerSets.length),
                ),
          if (_history.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 32, thickness: 2),
                    const Text(
                      'History (last 5 completed):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._history.map(
                      (entry) => Card(
                        color: Colors.orange.shade50,
                        child: ListTile(
                          leading: const Icon(
                            Icons.history,
                            color: Colors.deepOrange,
                          ),
                          title: Text(entry.name),
                          subtitle: Text(
                            'Completed: ${_formatDateTime(entry.completedAt)}\nPoints: ${entry.totalSeconds}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SavedSetsHeader extends SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;
  final Widget child;

  SavedSetsHeader({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(SavedSetsHeader oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.minExtent != minExtent ||
        oldDelegate.maxExtent != maxExtent;
  }
}

// Dialog for editing a timer set
class EditTimerSetDialog extends StatefulWidget {
  final SavedTimerSet timerSet;
  const EditTimerSetDialog({super.key, required this.timerSet});

  @override
  State<EditTimerSetDialog> createState() => _EditTimerSetDialogState();
}

class _EditTimerSetDialogState extends State<EditTimerSetDialog> {
  late TextEditingController _nameController;
  late List<TextEditingController> _secondsControllers;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.timerSet.name);
    _secondsControllers = widget.timerSet.secondsList
        .map((s) => TextEditingController(text: s.toString()))
        .toList();
    if (_secondsControllers.isEmpty) {
      _secondsControllers.add(TextEditingController());
    }
  }

  void _addSecondsField() {
    setState(() {
      _secondsControllers.add(TextEditingController());
    });
  }

  void _removeSecondsField(int index) {
    if (_secondsControllers.length > 1) {
      setState(() {
        _secondsControllers[index].dispose();
        _secondsControllers.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _secondsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Timer Set'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Set Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _secondsControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: _secondsControllers[index],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Sec ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeSecondsField(index),
                      ),
                      const SizedBox(width: 4),
                    ],
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addSecondsField,
                icon: const Icon(Icons.add),
                label: const Text('Add Seconds'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final secondsList = _secondsControllers
                .map((c) => int.tryParse(c.text) ?? 0)
                .where((s) => s > 0)
                .toList();
            if (name.isNotEmpty && secondsList.isNotEmpty) {
              Navigator.pop(
                context,
                SavedTimerSet(name: name, secondsList: secondsList),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Timer set screen (runs through all seconds in the set)
class TimerSetScreen extends StatefulWidget {
  final SavedTimerSet timerSet;
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
  bool _showPointsButton = false;
  bool _pointsClaimed = false;

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
      _showPointsButton = false;
      _pointsClaimed = false;
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
            _showPointsButton = true;
          });
          _animationController.stop();
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
      _showPointsButton = false;
      _pointsClaimed = false;
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
              _showPointsButton = true;
            });
            _animationController.stop();
          }
        }
      });
    }
  }

  void _claimPoints() {
    if (_pointsClaimed) return;
    setState(() {
      _pointsClaimed = true;
    });
    int points = _secondsList.fold(0, (a, b) => a + b);
    Navigator.pop(
      context,
      TimerSetHistoryEntry(
        name: widget.timerSet.name,
        completedAt: DateTime.now(),
        totalSeconds: points,
      ),
    );
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
              if (finished && _showPointsButton && !_pointsClaimed)
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 24,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.star, size: 36),
                    label: const Text('Claim Points!'),
                    onPressed: _claimPoints,
                  ),
                ),
              if (finished && _pointsClaimed)
                const Padding(
                  padding: EdgeInsets.only(top: 24.0),
                  child: Text(
                    'Points claimed!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              if (finished && !_showPointsButton)
                const Padding(
                  padding: EdgeInsets.only(top: 24.0),
                  child: Text(
                    'All stages finished!',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
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
