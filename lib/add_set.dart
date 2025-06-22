import 'package:flutter/material.dart';
import 'edit_set.dart';

class SavedTimerSet {
  String name;
  List<int> secondsList;
  SavedTimerSet({required this.name, required this.secondsList});

  Map<String, dynamic> toJson() => {'name': name, 'secondsList': secondsList};

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
    TextEditingController(),
  ];
  final List<bool> _invalidFields = [false];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _secondsControllers) {
      c.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _addSecondsField() {
    setState(() {
      _secondsControllers.add(TextEditingController());
      _invalidFields.add(false);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _removeSecondsField(int index) {
    if (_secondsControllers.length > 1) {
      setState(() {
        _secondsControllers.removeAt(index);
        _invalidFields.removeAt(index);
      });
    }
  }

  void _validateSecondsFields() {
    setState(() {
      for (int i = 0; i < _secondsControllers.length; i++) {
        final text = _secondsControllers[i].text.trim();
        _invalidFields[i] = text.isNotEmpty && !RegExp(r'^\d+$').hasMatch(text);
      }
    });
  }

  void _save() {
    final name = _nameController.text.trim();
    bool hasNonNumber = false;
    final secondsList = <int>[];

    for (int i = 0; i < _secondsControllers.length; i++) {
      final text = _secondsControllers[i].text.trim();
      if (text.isEmpty) continue;
      if (!RegExp(r'^\d+$').hasMatch(text)) {
        hasNonNumber = true;
        setState(() {
          _invalidFields[i] = true;
        });
        break;
      }
      final value = int.tryParse(text);
      if (value == null || value <= 0) {
        hasNonNumber = true;
        setState(() {
          _invalidFields[i] = true;
        });
        break;
      }
      secondsList.add(value);
    }

    if (hasNonNumber) {
      return;
    }

    if (name.isNotEmpty && secondsList.isNotEmpty) {
      final newSet = SavedTimerSet(name: name, secondsList: secondsList);
      Navigator.pop(context, newSet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Timer Set'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Set Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 80,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _secondsControllers.length,
                itemBuilder: (context, index) {
                  return KeyedSubtree(
                    key: ValueKey(_secondsControllers[index]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                                onChanged: (_) => _validateSecondsFields(),
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
                        ),
                        if (_invalidFields.length > index &&
                            _invalidFields[index])
                          SizedBox(
                            width: 90,
                            child: const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Numbers Only',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                      ],
                    ),
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
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
