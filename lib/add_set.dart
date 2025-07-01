import 'package:flutter/material.dart';

class SavedTimerSet {
  String name;
  List<int> secondsList;
  SavedTimerSet({required this.name, required this.secondsList});

  Map<String, dynamic> toJson() => {
        'name': name,
        'secondsList': secondsList,
      };

  factory SavedTimerSet.fromJson(Map<String, dynamic> json) => SavedTimerSet(
        name: json['name'],
        secondsList: List<int>.from(json['secondsList']),
      );
}

class AddSetPage extends StatefulWidget {
  const AddSetPage({super.key});

  @override
  State<AddSetPage> createState() => _AddSetPageState();
}

class _AddSetPageState extends State<AddSetPage> {
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _secondsControllers = [
    TextEditingController()
  ];

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _secondsControllers) {
      c.dispose();
    }
    super.dispose();
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

  void _saveSet() {
    final name = _nameController.text.trim();
    final secondsList = _secondsControllers
        .map((c) => int.tryParse(c.text) ?? 0)
        .where((s) => s > 0)
        .toList();
    if (name.isNotEmpty && secondsList.isNotEmpty) {
      final set = SavedTimerSet(name: name, secondsList: secondsList);
      Navigator.pop(context, set);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Timer Set')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Set Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
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
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveSet,
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}