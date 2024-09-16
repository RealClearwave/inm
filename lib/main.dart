import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:inm/pages/dictionary.dart';
import 'package:inm/pages/reader.dart';
import 'package:inm/pages/settings.dart';
import 'package:inm/pages/wordbank.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'inm',
      theme: ThemeData(
        primarySwatch: Colors.pink, // 主题色调为粉色
        scaffoldBackgroundColor: Colors.white, // 全局背景颜色为白色
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.pink), // 聚焦时边框为粉色
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.pink), // 普通状态下边框为粉色
          ),
          labelStyle: TextStyle(color: Colors.pink), // 提示文本的颜色为粉色
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.pink, // 加载符号的颜色为粉色
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;  // 当前选中的页面索引

  static const List<Widget> _pages = [
    ReaderPage(),
    DictionaryPage(),
    WordBankPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 每个页面背景为白色
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Colors.grey.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: GNav(
          gap: 8,
          color: Colors.pink.shade200,
          activeColor: Colors.pink.shade300,
          tabBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.all(16),
          onTabChange: _onItemTapped,
          tabs: const [
            GButton(
              icon: Icons.book,
              text: '阅读',
            ),
            GButton(
              icon: Icons.translate,
              text: '辞书',
            ),
            GButton(
              icon: Icons.library_books,
              text: '背词',
            ),
            GButton(
              icon: Icons.settings,
              text: '设置',
            ),
          ],
        ),
      ),
    );
  }
}
