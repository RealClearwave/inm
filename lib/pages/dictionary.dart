import 'package:flutter/material.dart';
import '../components/dictview.dart';

class DictionaryPage extends StatefulWidget {
  final String? initialQuery;  // 从其他页面传来的词语

  const DictionaryPage({super.key, this.initialQuery});

  @override
  _DictionaryPageState createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _query = widget.initialQuery!;
      _controller.text = _query;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('辞书'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: '请输入词语',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: DictView(query: _query),  // 显示查询结果
            ),
          ],
        ),
      ),
    );
  }
}
