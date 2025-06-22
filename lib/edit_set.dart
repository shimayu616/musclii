import 'package:flutter/material.dart';
import 'add_set.dart';

class EditSetPage extends StatefulWidget {
  final SavedTimerSet timerSet;
  const EditSetPage({super.key, required this.timerSet});

  @override
  State<EditSetPage> createState() => _EditSetPageState();
}

class _EditSetPageState extends State<EditSetPage> {
  late TextEditingController _nameController;
  late List<TextEditingController> _secondsControllers;
  late List<bool> _invalidFields;
  late ScrollController _scrollController;

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
    // FIX: Make the list growable!
    _invalidFields = List<bool>.filled(
      _secondsControllers.length,
      false,
      growable: true,
    );
    for (final c in _secondsControllers) {
      c.addListener(_validateSecondsFields);
    }
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _secondsControllers) {
      c.removeListener(_validateSecondsFields);
      c.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _addSecondsField() {
    final controller = TextEditingController();
    controller.addListener(_validateSecondsFields);
    setState(() {
      _secondsControllers.add(controller);
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
      final controller = _secondsControllers[index];
      controller.removeListener(_validateSecondsFields);
      setState(() {
        _secondsControllers.removeAt(index);
        _invalidFields.removeAt(index);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.dispose();
      });
      _validateSecondsFields();
    }
  }

  void _validateSecondsFields() {
    setState(() {
      _invalidFields = List<bool>.from(
        _secondsControllers.map((c) {
          final text = c.text.trim();
          if (text.isEmpty) return false;
          return !RegExp(r'^\d+$').hasMatch(text);
        }),
      );
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
      final editedSet = SavedTimerSet(name: name, secondsList: secondsList);
      Navigator.pop(context, editedSet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Timer Set'),
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
