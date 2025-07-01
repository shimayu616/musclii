import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_set.dart';
import 'auth_gate.dart';
import 'timer_launch.dart';
import 'edit_set.dart';

class TimerSetListPage extends StatefulWidget {
  const TimerSetListPage({super.key});
  @override
  State<TimerSetListPage> createState() => _TimerSetListPageState();
}

class _TimerSetListPageState extends State<TimerSetListPage> {
  List<SavedTimerSet> _timerSets = []; // In-memory only

  void _addSet() async {
    final result = await Navigator.push<SavedTimerSet>(
      context,
      MaterialPageRoute(builder: (context) => const AddSetPage()),
    );
    if (result != null) {
      setState(() {
        _timerSets.add(result);
      });
    }
  }

  void _editSet(int index) async {
    final result = await Navigator.push<SavedTimerSet>(
      context,
      MaterialPageRoute(
        builder: (context) => EditSetPage(timerSet: _timerSets[index]),
      ),
    );
    if (result != null) {
      setState(() {
        _timerSets[index] = result;
      });
    }
  }

  void _removeSet(int index) {
    setState(() {
      _timerSets.removeAt(index);
    });
  }

  void _startTimer(SavedTimerSet set) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimerSetScreen(timerSet: set)),
    );
    // No history reload needed
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSet,
        icon: const Icon(Icons.add),
        label: const Text('Add Set'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 24, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Saved Sets',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _timerSets.isEmpty
                ? const Center(child: Text('No timer sets saved.'))
                : ListView.builder(
                    itemCount: _timerSets.length,
                    itemBuilder: (context, idx) {
                      final set = _timerSets[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 2,
                        ),
                        child: Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.timer,
                              color: Colors.deepOrange,
                              size: 36,
                            ),
                            title: Text(
                              set.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'Stages: ${set.secondsList.length}\nSeconds: ${set.secondsList.join(", ")}',
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _startTimer(set),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _editSet(idx),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeSet(idx),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 24, top: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'History (last 5 completed):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          // No history list, only the header
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
