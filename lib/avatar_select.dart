import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvatarSelectPage extends StatefulWidget {
  const AvatarSelectPage({super.key});

  @override
  State<AvatarSelectPage> createState() => _AvatarSelectPageState();
}

class _AvatarSelectPageState extends State<AvatarSelectPage> {
  String? _selectedAvatar; // 'men_3.png' or 'women_3.png'
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveAvatar() async {
    if (_selectedAvatar == null || _nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'avatar': _selectedAvatar,
        'avatarName': _nameController.text.trim(),
      }, SetOptions(merge: true));
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('アバターを選択')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('アバターを選んで名前をつけてください', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = 'men_3.png'),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedAvatar == 'men_3.png'
                            ? Colors.blue
                            : Colors.transparent,
                        width: 3,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('lib/media/men_3.png'),
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = 'women_3.png'),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedAvatar == 'women_3.png'
                            ? Colors.pink
                            : Colors.transparent,
                        width: 3,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('lib/media/women_3.png'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'アバターの名前',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveAvatar,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}