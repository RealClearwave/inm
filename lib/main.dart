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
        primarySwatch: Colors.pink,
      ),
      home: const MainScreen(),  // 主页面
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

  // 切换的页面
  static const List<Widget> _pages = [
    ReaderPage(),
    DictionaryPage(),
    WordBankPage(),
    SettingsPage(),
  ];

  // 页面选择处理函数
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],  // 显示当前页面
      bottomNavigationBar: Container(
        color: Colors.grey.shade100,  // 导航栏背景颜色
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: GNav(
          gap: 8,  // 图标和文字之间的距离
          color: Colors.pink.shade200,  // 图标颜色
          activeColor: Colors.pink.shade300,  // 选中的颜色
          tabBackgroundColor: Colors.grey.shade300,  // 选中的背景颜色
          padding: const EdgeInsets.all(16),
          onTabChange: _onItemTapped,  // 点击切换页面
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
