import 'package:flutter/material.dart';
import 'main_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'avatar_select.dart';

class AppNav extends StatefulWidget {
  const AppNav({super.key});

  @override
  State<AppNav> createState() => _AppNavState();
}

class _AppNavState extends State<AppNav> {
  int _currentIndex = 0;
  String? _avatarPath;
  String? _avatarName;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data()?['avatar'] == null || doc.data()?['avatarName'] == null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AvatarSelectPage()),
      );
      if (result != true) return;
      final newDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _avatarPath = newDoc.data()?['avatar'];
        _avatarName = newDoc.data()?['avatarName'];
      });
    } else {
      setState(() {
        _avatarPath = doc.data()?['avatar'];
        _avatarName = doc.data()?['avatarName'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeSamplePage(avatarPath: _avatarPath, avatarName: _avatarName, onAvatarUpdated: _loadAvatar),
      const TimerSetListPage(),
      const ProfileSamplePage(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'セット',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
      ),
    );
  }
}

class HomeSamplePage extends StatelessWidget {
  final String? avatarPath;
  final String? avatarName;
  final VoidCallback? onAvatarUpdated;
  const HomeSamplePage({super.key, this.avatarPath, this.avatarName, this.onAvatarUpdated});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (avatarPath != null)
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('lib/media/$avatarPath'),
            ),
          if (avatarPath == null)
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AvatarSelectPage(),
                  ),
                );
                if (result == true && onAvatarUpdated != null) {
                  onAvatarUpdated!();
                }
              },
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blueAccent,
                        width: 3,
                        style: BorderStyle.solid,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1,
                      size: 60,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'アバター未設定\nタップして設定',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (avatarName != null && avatarPath != null)
            Text(
              avatarName!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class ProfileSamplePage extends StatelessWidget {
  const ProfileSamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プロフィール')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('lib/media/men_3.png'), // 仮画像
            ),
            const SizedBox(height: 16),
            const Text(
              'ユーザー名',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('メールアドレス: sample@example.com'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // プロフィール編集画面へ遷移など
              },
              child: const Text('プロフィール編集'),
            ),
          ],
        ),
      ),
    );
  }
}