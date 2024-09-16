import 'package:flutter/material.dart';
import '../modules/qzutil.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLevel = QzUtil.selectedLevel;

  @override
  void initState() {
    super.initState();
    _loadSelectedLevel();
  }

  Future<void> _loadSelectedLevel() async {
    await QzUtil.init();
    setState(() {
      _selectedLevel = QzUtil.selectedLevel;
    });
  }

  Future<void> _saveSelectedLevel(String level) async {
    await QzUtil.saveSelectedLevel(level);
    setState(() {
      _selectedLevel = level;
    });
  }

  Future<void> _resetProgress() async {
    QzUtil.progress.clear();
    await QzUtil.saveProgress();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('背诵进度已重置')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Colors.pink[50],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '选择词汇级别：',
              style: TextStyle(fontSize: 18),
            ),
            DropdownButton<String>(
              value: _selectedLevel,
              items: ['n1', 'n2', 'n3', 'n4', 'n5']
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _saveSelectedLevel(value);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetProgress,
              child: const Text('重置背诵进度'),
            ),
          ],
        ),
      ),
    );
  }
}
