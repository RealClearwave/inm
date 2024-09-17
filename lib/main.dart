import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:inm/pages/dictionary.dart';
import 'package:inm/pages/reader.dart';
import 'package:inm/pages/settings.dart';
import 'package:inm/pages/quiz.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.grey.shade100, // 设置导航条颜色
      systemNavigationBarIconBrightness: Brightness.dark, // 图标颜色
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'inm日本語',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // 背景色为白色
        primarySwatch: Colors.pink, // 主题色调为粉色
        // 按钮主题颜色
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.pink.shade300, backgroundColor: Colors.pink.shade50, // 按钮文字颜色
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.pink.shade300, // 文本按钮颜色
          ),
        ),

        // Switch 主题颜色
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.pink.shade300), // 开关按钮颜色
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.pink.shade100; // 开启时的轨道颜色
            }
            return Colors.brown.shade200; // 关闭时的轨道颜色
          }),
        ),

        // ListTile 主题颜色
        listTileTheme: ListTileThemeData(
          iconColor: Colors.pink.shade300, // 图标颜色
          textColor: Colors.black, // 文字颜色
          selectedTileColor: Colors.pink.shade50, // 选中时的背景颜色
        ),

        // InputDecoration 主题，控制 TextField 等输入控件的颜色
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.pink), // 聚焦时边框为粉色
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.pink), // 普通状态下边框为粉色
          ),
          labelStyle: TextStyle(color: Colors.pink), // 提示文本的颜色为粉色
        ),

        // 进度指示器颜色
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
    QuizPage(),
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
              text: '読み',
            ),
            GButton(
              icon: Icons.translate,
              text: '辞書',
            ),
            GButton(
              icon: Icons.library_books,
              text: '暗記',
            ),
            GButton(
              icon: Icons.settings,
              text: '設定',
            ),
          ],
        ),
      ),
    );
  }
}
