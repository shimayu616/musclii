import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_set.dart';
import 'auth_gate.dart';
import 'timer_launch.dart';
import 'edit_set.dart';
import 'timer_history.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TimerSetListPage extends StatefulWidget {
  const TimerSetListPage({super.key});
  @override
  State<TimerSetListPage> createState() => _TimerSetListPageState();
}

class _TimerSetListPageState extends State<TimerSetListPage> {
  final List<SavedTimerSet> _timerSets = [];
  int _totalPoints = 0;
  List<TimerSetHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _loadTimerSets().then((_) => _loadHistory());
  }

  Future<void> _saveTimerSets() async {
    final prefs = await SharedPreferences.getInstance();
    final setsJson = _timerSets.map((set) => jsonEncode(set.toJson())).toList();
    await prefs.setStringList('timerSets', setsJson);
  }

  Future<void> _loadTimerSets() async {
    final prefs = await SharedPreferences.getInstance();
    final setsJson = prefs.getStringList('timerSets') ?? [];
    setState(() {
      _timerSets.clear();
      for (final s in setsJson) {
        try {
          final map = jsonDecode(s);
          _timerSets.add(SavedTimerSet.fromJson(map));
        } catch (_) {}
      }
    });
  }

  Future<void> _loadHistory() async {
    final history = await loadHistory();
    setState(() {
      _history = history;
      _totalPoints = _history.fold(0, (sum, entry) => sum + entry.totalSeconds);
    });
  }

  void _removeTimerSet(int index) async {
    setState(() {
      _timerSets.removeAt(index);
    });
    await _saveTimerSets();
  }

  void _editTimerSet(int index) async {
    final edited = await Navigator.push<SavedTimerSet>(
      context,
      MaterialPageRoute(
        builder: (context) => EditSetPage(timerSet: _timerSets[index]),
      ),
    );
    if (edited != null) {
      setState(() {
        _timerSets[index] = edited;
      });
      await _saveTimerSets();
    }
  }

  void _goToTimerScreen(SavedTimerSet timerSet) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimerSetScreen(timerSet: timerSet),
      ),
    );
    // Reload history after returning from timer screen
    await _loadHistory();
    // Reload sets in case of any changes
    await _loadTimerSets();
  }

  Future<void> _navigateToAddSet() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSetPage()),
    );
    if (result is SavedTimerSet) {
      setState(() {
        _timerSets.add(result);
      });
      await _saveTimerSets();
    }
  }

  String _formatDateTime(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'ログインに戻る',
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthGate()),
                (route) => false,
              );
            }
          },
        ),
        title: const Text('Saved Timer Sets'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Total Points: $_totalPoints',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.deepOrange,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final savedSetsHeight = constraints.maxHeight * 0.6;
          final historyHeight = constraints.maxHeight * 0.4;
          return Column(
            children: [
              // Saved Sets Section (60% of screen)
              SizedBox(
                height: savedSetsHeight,
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 16,
                        bottom: 8,
                      ),
                      child: const Text(
                        'Saved Sets',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    if (_timerSets.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: const Center(
                          child: Text('No timer sets saved.'),
                        ),
                      )
                    else
                      ..._timerSets.asMap().entries.map((entry) {
                        final index = entry.key;
                        final timerSet = entry.value;
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
                      }),
                  ],
                ),
              ),
              // History Section (40% of screen)
              SizedBox(
                height: historyHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 32, thickness: 2),
                    const Padding(
                      padding: EdgeInsets.only(left: 24, bottom: 8),
                      child: Text(
                        'History (last 5 completed):',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _history.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.only(left: 32, top: 8),
                              child: Text('No history yet.'),
                            )
                          : ListView.builder(
                              itemCount: _history.length,
                              itemBuilder: (context, idx) {
                                final entry = _history[idx];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 2,
                                  ),
                                  child: Card(
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
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddSet,
        icon: const Icon(Icons.add),
        label: const Text('Add Set'),
      ),
    );
  }
}
