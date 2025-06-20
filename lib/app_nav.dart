import 'package:flutter/material.dart';
import 'main_page.dart';

class AppNav extends StatefulWidget {
  const AppNav({super.key});

  @override
  State<AppNav> createState() => _AppNavState();
}

class _AppNavState extends State<AppNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeSamplePage(),
    const TimerSetListPage(),
    const ProfileSamplePage(),
  ];

  @override
  Widget build(BuildContext context) {
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
  const HomeSamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'ホーム画面サンプル',
        style: TextStyle(fontSize: 24),
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
              backgroundImage: AssetImage('assets/profile_placeholder.png'), // 適宜画像を用意
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
                // 例: プロフィール編集画面へ遷移など
              },
              child: const Text('プロフィール編集'),
            ),
          ],
        ),
      ),
    );
  }
}