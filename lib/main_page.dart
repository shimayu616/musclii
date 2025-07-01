import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_set.dart';
import 'auth_gate.dart';
import 'timer_launch.dart';
import 'edit_set.dart';
import 'timer_history.dart';

class TimerSetListPage extends StatefulWidget {
  const TimerSetListPage({super.key});
  @override
  State<TimerSetListPage> createState() => _TimerSetListPageState();
}

class _TimerSetListPageState extends State<TimerSetListPage> {
  List<SavedTimerSet> _timerSets = [];
  List<TimerSetHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _loadTimerSets();
    _loadHistory();
  }

  Future<void> _loadTimerSets() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('sets')
        .get();
    setState(() {
      _timerSets = snapshot.docs
          .map((doc) => SavedTimerSet.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> _saveTimerSet(SavedTimerSet set) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('sets')
        .doc(set.name)
        .set(set.toJson());
    await _loadTimerSets();
  }

  Future<void> _removeTimerSet(int index) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final set = _timerSets[index];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('sets')
        .doc(set.name)
        .delete();
    await _loadTimerSets();
  }

  Future<void> _loadHistory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('history')
        .orderBy('completedAt', descending: true)
        .limit(5)
        .get();
    setState(() {
      _history = snapshot.docs
          .map((doc) => TimerSetHistoryEntry.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> _saveHistoryEntry(TimerSetHistoryEntry entry) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('history');
    await ref.add(entry.toJson());

    // 5件を超えたら古いものを削除
    final snapshot = await ref.orderBy('completedAt', descending: true).get();
    if (snapshot.docs.length > 5) {
      for (final doc in snapshot.docs.skip(5)) {
        await doc.reference.delete();
      }
    }
    await _loadHistory();
  }

  void _addSet() async {
    final result = await Navigator.push<SavedTimerSet>(
      context,
      MaterialPageRoute(builder: (context) => const AddSetPage()),
    );
    if (result != null) {
      await _saveTimerSet(result);
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
      await _saveTimerSet(result);
    }
  }

  void _removeSet(int index) async {
    await _removeTimerSet(index);
  }

  void _startTimer(SavedTimerSet set) async {
    final result = await Navigator.push<TimerSetHistoryEntry>(
      context,
      MaterialPageRoute(builder: (context) => TimerSetScreen(timerSet: set)),
    );
    if (result != null) {
      await _saveHistoryEntry(result);
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
          if (_history.isNotEmpty)
            Expanded(
              flex: 1,
              child: ListView(
                children: _history.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 2),
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
                }).toList(),
              ),
            ),
          if (_history.isEmpty)
            const SizedBox(height: 32),
        ],
      ),
    );
  }
}