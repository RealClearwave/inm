import 'package:flutter/services.dart';
import '../components/furigana.dart';  // 导入 FuriganaChar 组件

class SemanticParser {
  static const platform = MethodChannel('com.clearwave.inm/tokenize');

  // 调用 Kuromoji 分词
  Future<String> tokenizeText(String text) async {
    try {
      // 从 Java 端获取返回的分词字符串
      final String result = await platform.invokeMethod('tokenize', {'text': text});
      return result;
    } on PlatformException catch (e) {
      //print("Tokenize Failed: '${e.message}'.");
      throw Exception("Tokenize Failed: '${e.message}'.");
    }
  }

  Future<List<List<List<FuriganaChar>>>> parsePages(List<List<String>> pages) async {
    //'ᶲ' for sentence split, 'ᶳ' for page split
    String result = pages.map((page) => page.join('ᶳ')).join('ᶲ');

    String parsedString = await tokenizeText(result);
    
    List<List<List<FuriganaChar>>> parsedPages = [];
    List<String> pageStrings = parsedString.split('ᶲ');
    for (String pageString in pageStrings) {
      List<String> sentenceStrings = pageString.split('ᶳ');
      List<List<FuriganaChar>> page = [];
      for (String sentenceString in sentenceStrings) {
        List<FuriganaChar> sentence = parseKuromojiResult(sentenceString);
        page.add(sentence);
      }
      parsedPages.add(page);
    }
    return parsedPages;
  }

  // 分句函数
  List<String> splitSentences(String text) {
    List<String> sentences = [];
    bool insideQuote = false; // 用于跟踪是否在「」内部
    bool afterQuote = false;  // 用于跟踪是否在」之后的内容

    text = text.replaceAll(RegExp(r'\s'), '');
    String currentSentence ="";
    for (var surface in text.split('')) {
      currentSentence += surface;
      // 如果遇到「，进入引号内容
      if (surface == "「") {
        insideQuote = true;
        afterQuote = false;
        continue;
      }

      // 如果遇到」后，继续记录后面的内容直到句子结束符
      if (surface == "」") {
        insideQuote = false;  // 引号结束
        afterQuote = true;    // 标记引号后内容属于该句
        continue;
      }

      // 如果不是在引号中或引号后，并遇到句子结束符（如 "。", "！", "？"），结束当前句子
      if (!insideQuote && !afterQuote && ["。", "！", "？"].contains(surface)) {
        sentences.add(currentSentence);
        currentSentence = "";
      }

      // 如果已经在引号之后，遇到句子结束符则结束当前句子
      if (afterQuote && ["。", "！", "？"].contains(surface)) {
        sentences.add(currentSentence);
        currentSentence = "";
        afterQuote = false; // 结束引号后的追加部分
      }
    }

    return sentences;
  }

  List<List<String>> buildPages(List<String> sentences) {
    List<List<String>> pages = [];
    int pageSize = 5;
    int pageCount = (sentences.length / pageSize).ceil();

    for (int i = 0; i < pageCount; i++) {
      int startIndex = i * pageSize;
      int endIndex = (i + 1) * pageSize;
      if (endIndex > sentences.length) {
        endIndex = sentences.length;
      }
      List<String> page = sentences.sublist(startIndex, endIndex);
      pages.add(page);
    }

    return pages;
  }

  // 解析 Kuromoji 返回的结果字符串并转换为句子列表，每个句子由多个 FuriganaChar 组成
  List<FuriganaChar> parseKuromojiResult(String result) {
    List<FuriganaChar> currentSentence = [];

    // 每一行表示一个分词结果
    List<String> lines = result.split('\n');
    for (String line in lines) {
      if (line.isEmpty) continue;

      // 每行使用制表符 '\t' 分隔，第一部分是表面形，第二部分是所有特性
      List<String> parts = line.split('\t');
      if (parts.length < 2) continue;

      String surface = parts[0]; // 汉字或假名
      String features = parts[1]; // 其他特性

      // 根据分词结果中的特性来决定是否有平假名、加粗、下划线等
      List<String> featureParts = features.split(',');

      // 从特性中提取假名，如果没有，保持为 null
      String? furigana = featureParts.length > 7 ? featureParts[7] : null;

      // 如果是标点符号，furigana 设置为空格
      final punctuationMarks = ['。', '、', '？', '！', '「', '」', '『', '』', '・', '…', '—', '（', '）', '［', '］'];
      if (punctuationMarks.contains(surface)) {
        furigana = ' ';
      }

      bool bold = false;
      bool underline = featureParts[0] == '動詞'; // 如果是动词，设为下划线

      // 创建 FuriganaChar
      FuriganaChar furiganaChar = FuriganaChar(
        kanji: surface,
        furigana: furigana,
        bold: bold,
        underline: underline,
      );

      currentSentence.add(furiganaChar);
    }

    return currentSentence;
  }
}
