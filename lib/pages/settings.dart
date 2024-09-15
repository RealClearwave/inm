import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _logs = '';

  @override
  void initState() {
    super.initState();
    _loadLogs();  // 加载日志
  }

  // 加载日志
  Future<void> _loadLogs() async {
    setState(() {
      _logs = "Deprecated: 'LogManager' is no longer available.";
    });
  }

  // 清除日志
  Future<void> _clearLogs() async {
    _loadLogs();  // 清除后重新加载日志
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '应用日志',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _logs.isEmpty ? '暂无日志' : _logs,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _clearLogs,
              child: const Text('清除日志'),
            ),
          ],
        ),
      ),
    );
  }
}
