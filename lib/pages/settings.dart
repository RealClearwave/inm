// lib/pages/settings.dart
import 'package:flutter/material.dart';
import '../modules/qzutil.dart';
import '../modules/transutil.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLevel = QzUtil.selectedLevel;
  bool _isTranslationEnabled = false;
  final TextEditingController _apiUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await QzUtil.init();
    final TransUtil _transUtil = TransUtil();
    await _transUtil.init();

    print('启用：${_transUtil.isTranslationEnabled}, URL：${_transUtil.apiUrl}');
    setState(() {
      _selectedLevel = QzUtil.selectedLevel;
      _isTranslationEnabled = _transUtil.isTranslationEnabled;
      _apiUrlController.text = _transUtil.apiUrl;
    });
  }

  Future<void> _saveTranslationSettings() async {
    // 更新 TransUtil 的设置
    TransUtil().setTranslationEnabled(_isTranslationEnabled);
    TransUtil().setApiUrl(_apiUrlController.text);
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
        title: const Text('设置'),
        backgroundColor: Colors.pink[50],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              const Divider(height: 40),
              // 添加翻译设置
              SwitchListTile(
                title: const Text('启用翻译'),
                value: _isTranslationEnabled,
                onChanged: (value) {
                  setState(() {
                    _isTranslationEnabled = value;
                  });
                  _saveTranslationSettings();
                },
              ),
              const SizedBox(height: 10),
              if (_isTranslationEnabled)
                TextField(
                  controller: _apiUrlController,
                  decoration: const InputDecoration(
                    labelText: '翻译 API URL',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _saveTranslationSettings();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
