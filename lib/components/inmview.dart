// lib/components/inmview.dart
import 'package:flutter/material.dart';
import '../components/furigana.dart';  // 导入 FuriganaText 组件
import '../modules/transutil.dart';   // 导入 TransUtil

class InmView extends StatefulWidget {
  final List<List<FuriganaChar>> pageContent;  // 当前页显示的句子
  final List<String> originalSentences;        // 原始的句子文本

  const InmView({
    super.key,
    required this.pageContent,
    required this.originalSentences,
  });

  @override
  _InmViewState createState() => _InmViewState();
}

class _InmViewState extends State<InmView> {
  final TransUtil _transUtil = TransUtil();
  List<String?> _translations = []; // 存储翻译结果

  @override
  void initState() {
    super.initState();
    _translations = List<String?>.filled(widget.pageContent.length, null);
    _transUtil.init();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.pageContent.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            FuriganaText(furiganaChars: widget.pageContent[index]),
            if (_transUtil.isTranslationEnabled)
              _buildTranslationSection(index),
            const SentenceSplitLine(),
          ],
        );
      },
    );
  }

  Widget _buildTranslationSection(int index) {
    return Column(
      children: [
        _translations[index] == null
            ? TextButton(
                onPressed: () => _showTranslation(index),
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(Colors.pink.shade300),
                ),
                child: const Text('查看翻译'),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _translations[index]!,
                  style: const TextStyle(color: Colors.pink),
                ),
              ),
      ],
    );
  }

  void _showTranslation(int index) async {
    String originalText = widget.originalSentences[index];

    setState(() {
      _translations[index] = '正在翻译...';
    });

    String translation = await _transUtil.translate(originalText);

    setState(() {
      _translations[index] = translation.isNotEmpty ? translation : '翻译失败';
    });
  }
}

class SentenceSplitLine extends StatelessWidget {
  const SentenceSplitLine({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 6),
      height: 1,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          const dashWidth = 5.0;
          const dashSpace = 3.0;
          final dashCount =
              (constraints.constrainWidth() / (dashWidth + dashSpace)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return const SizedBox(
                width: dashWidth,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.grey),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
