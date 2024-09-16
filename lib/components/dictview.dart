import 'package:flutter/material.dart';
import '../modules/tblookup.dart';  // 引入查询模块
import '../components/furigana.dart';  // 引入 Furigana 用于日文解析
import '../modules/semantic.dart';  // 引入 Kuromoji 解析模块

class DictView extends StatefulWidget {
  final String query;

  const DictView({super.key, required this.query});

  @override
  State<DictView> createState() => _DictViewState();
}

class _DictViewState extends State<DictView> {
  List<String> posSet = [];

  @override
  Widget build(BuildContext context) {
    // 如果查询词为空，返回提示
    if (widget.query.isEmpty) {
      return const Center(
        child: Text(
          '请输入要查询的词汇',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    // 查询词不为空时，执行查询
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: TbLookup.lookup(widget.query),  // 查询词语
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('查询失败 : ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('未找到结果'));
        } else {
          final allJapaneseExamples = _getAllJapaneseExamples(snapshot.data!);  // 获取所有日语例句
          final allTranslations = _getAllTranslations(snapshot.data!);  // 获取所有翻译
          return FutureBuilder<List<List<FuriganaChar>>>(
            future: _parseAllExamples(allJapaneseExamples, widget.query),  // 解析所有合并的日语例句
            builder: (context, parsedSnapshot) {
              if (parsedSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (parsedSnapshot.hasError || !parsedSnapshot.hasData) {
                return const Center(child: Text('解析失败'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final result = snapshot.data![index];
                    String word = result['word'];
                    String kana = result['kana'];
                    List<String> definitions = result['definition'].split('（');

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. 词汇 - 大字号显示
                          Row(
                            children: [
                              Text(
                                word,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                kana,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // 2. 假名 - 小字号显示   
                          Text(
                            posSet.toSet().join(', '),  // 异步显示去重后的posSet
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 3. 释义和例句
                          ...definitions.asMap().entries.map((entry) {
                            int definitionIndex = entry.key + 1;
                            String definitionText = entry.value;
                            return _buildDefinitionItem(
                                context, definitionIndex, definitionText, word, parsedSnapshot.data!, allTranslations);
                          }),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          );
        }
      },
    );
  }

  // 获取所有日语例句并合并为一个字符串
  String _getAllJapaneseExamples(List<Map<String, dynamic>> data) {
    List<String> allJapaneseExamples = [];

    for (var result in data) {
      List<String> definitions = result['definition'].split('（');
      for (String definition in definitions) {
        List<String> examplePair = definition.split('▲').skip(1).toList();
        for (var example in examplePair) {
          List<String> parts = example.split('/');  // 分离日语和翻译
          allJapaneseExamples.add(parts[0]);  // 只保留日语部分
        }
      }
    }

    // 将所有日语例句合并为一个字符串，例句之间用特殊符号 '。'、'？'、'！' 分隔，方便后面分拆
    return allJapaneseExamples.join('。');
  }

  // 获取所有翻译
  List<String> _getAllTranslations(List<Map<String, dynamic>> data) {
    List<String> allTranslations = [];

    for (var result in data) {
      List<String> definitions = result['definition'].split('（');
      for (String definition in definitions) {
        List<String> examplePair = definition.split('▲').skip(1).toList();
        for (var example in examplePair) {
          List<String> parts = example.split('/');  // 分离日语和翻译
          if (parts.length > 1) {
            allTranslations.add(parts[1]);  // 保留翻译部分
          } else {
            allTranslations.add('');  // 如果没有翻译，保留空字符串
          }
        }
      }
    }

    return allTranslations;
  }

  // 构建释义和例句的显示
  Widget _buildDefinitionItem(BuildContext context, int index, String text, String word, List<List<FuriganaChar>> parsedExamples, List<String> allTranslations) {
    List<String> parsedDef = text.split('▲');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3.1 释义 - 使用圆角灰色方框包裹
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '(${parsedDef[0]}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        // 3.2 例句和翻译 - 解析过的 Furigana
        if (parsedDef.length > 1)
          _buildExampleItem(context, parsedExamples, word, parsedDef.length - 1, allTranslations),
      ],
    );
  }

  // 构建例句的显示，包含日文和翻译
  Widget _buildExampleItem(BuildContext context, List<List<FuriganaChar>> parsedExamples, String word, int exampleCount, List<String> allTranslations) {
    List<Widget> exampleWidgets = [];
    for (int i = 0; i < exampleCount; i++) {
      exampleWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 使用 Expanded 或 Flexible 包裹 FuriganaText 以启用自动换行
            Row(
              children: [
                const Column(
                  children: [
                    SizedBox(height: 18),
                    Text('☆'),
                  ],
                ),
                Expanded(  // 添加此行
                  child: FuriganaText(furiganaChars: parsedExamples[i]),  // 显示解析后的 Furigana
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (allTranslations[i].isNotEmpty)
              Text(
                allTranslations[i],
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: exampleWidgets,
    );
  }


  // 使用 Kuromoji 解析所有合并的日语例句，并返回解析后的结果
  Future<List<List<FuriganaChar>>> _parseAllExamples(String allJapaneseExamples, String word) async {
    final SemanticParser parser = SemanticParser();

    // 解析合并的所有日语例句
    String modifiedExamples = allJapaneseExamples.replaceAll('～', word);
    List<Map<String, dynamic>> parsedSentences = parser.parseKuromojiWithPos(await parser.tokenizeText(modifiedExamples));

    // 按句号 '。'、问号 '？'、感叹号 '！' 分隔，将解析结果按原例句顺序拆分为多个 FuriganaChar 列表
    List<List<FuriganaChar>> result = [];
    List<FuriganaChar> currentSentence = [];
    final sentenceEndRegex = RegExp(r'[。！？]');  // 匹配句号、问号和感叹号

    for (var entry in parsedSentences) {
      String kanji = entry['kanji'];
      String? furigana = entry['furigana'];
      currentSentence.add(FuriganaChar(
        kanji: kanji,
        furigana: furigana,
        underline: kanji == word,
        bold: kanji == word,
      ));

      // 如果当前字符匹配句子结束符，表示一个句子结束
      if (sentenceEndRegex.hasMatch(kanji)) {
        result.add(currentSentence);
        currentSentence = [];
      }
    }

    // 如果还有未处理的例句，加入结果
    if (currentSentence.isNotEmpty) {
      result.add(currentSentence);
    }

    return result;
  }
}
