import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'tblookup.dart';

class QzUtil {
  // 记录用户选定的级别（默认为 n5）
  static String selectedLevel = 'n5';

  // 记录用户的背诵进度，格式为：{'word': correctCount}
  static Map<String, int> progress = {};

  // 所有词汇列表
  static Map<String, List<String>> jlptWords = {};

  // 初始化，加载词汇表和背诵进度
  static Future<void> init() async {
    await _loadJlptWords();
    await _loadProgress();
    await _loadSelectedLevel();
  }

  static Future<void> _loadJlptWords() async {
      String data = await rootBundle.loadString('assets/dict/jlpt_words.json');
      Map<String, dynamic> jsonData = json.decode(data);
      
      // 将 dynamic 类型的 List 强制转换为 List<String>
      jlptWords = jsonData.map((key, value) {
        return MapEntry(key, List<String>.from(value));
      });
  }


  // 加载背诵进度
  static Future<void> _loadProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? progressString = prefs.getString('quiz_progress');
    if (progressString != null) {
      progress = Map<String, int>.from(json.decode(progressString));
    }
  }

  // 保存背诵进度
  static Future<void> saveProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String progressString = json.encode(progress);
    await prefs.setString('quiz_progress', progressString);
  }

  // 加载用户选定的级别
  static Future<void> _loadSelectedLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedLevel = prefs.getString('selectedLevel') ?? 'n5';
  }

  // 保存用户选定的级别
  static Future<void> saveSelectedLevel(String level) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLevel', level);
    selectedLevel = level;
  }

  // 获取未背诵的词汇列表
  static List<String> getUnlearnedWords() {
    List<String> words = jlptWords[selectedLevel] ?? [];
    return words.where((word) => (progress[word] ?? 0) < 3).toList();
  }
}

class QuizItem {
  static final Random _random = Random(); // 定义随机数生成器
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String type; // 题目类型

  QuizItem({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.type,
  });

  // 生成 QuizItem
  static Future<QuizItem> generate(String word) async {
    // 使用 TbLookup 查找 kana 和 definition
    List<Map<String, dynamic>> lookupResult = await TbLookup.lookup(word);
    if (lookupResult.isEmpty) {
      throw Exception('Word not found in dictionary');
    }
    String kana = lookupResult[0]['kana'];
    String definition = lookupResult[0]['definition'];

    // 随机选择题目类型
    int questionType = Random().nextInt(4); // 0-3

    switch (questionType) {
      case 0:
        // 根据汉字选假名
        return await _generateKanjiToKana(word, kana);
      case 1:
        // 根据假名选汉字
        return await _generateKanaToKanji(word, kana);
      case 2:
        // 根据汉字选释义
        return await _generateKanjiToDefinition(word, definition);
      case 3:
        // 根据释义选汉字
        return await _generateDefinitionToKanji(word, definition);
      default:
        // 默认返回汉字选假名
        return await _generateKanjiToKana(word, kana);
    }
  }

  // 根据汉字选假名
  static Future<QuizItem> _generateKanjiToKana(String word, String kana) async {
    List<String> options = await _generateFakeKanaOptions(kana);
    if (kana == '') {
      kana = word;
    }
    options.add(kana);
    options.shuffle();
    return QuizItem(
      question: word,
      options: options,
      correctAnswer: kana,
      type: 'kanji_to_kana',
    );
  }

  // 根据假名选汉字
  static Future<QuizItem> _generateKanaToKanji(String word, String kana) async {
    List<String> options = await _generateFakeKanjiOptions(word);
    if (kana == '') {
      kana = word;
    } 

    options.add(word);
    options.shuffle();
    return QuizItem(
      question: kana,
      options: options,
      correctAnswer: word,
      type: 'kana_to_kanji',
    );
  }

  // 根据汉字选释义
  static Future<QuizItem> _generateKanjiToDefinition(String word, String definition) async {
    List<String> options = await _generateFakeDefinitions(definition);
    List<String> parsedDefinition = definition.split(RegExp(r'（[０-９]+）'));
    if (parsedDefinition.length == 1) {
      parsedDefinition.add(definition);
    }
    String correctDefinition = ((parsedDefinition[1+_random.nextInt(parsedDefinition.length-1)]).split('▲'))[0];
    options.add(correctDefinition);
    options.shuffle();
    return QuizItem(
      question: word,
      options: options,
      correctAnswer: correctDefinition,
      type: 'kanji_to_definition',
    );
  }

  // 根据释义选汉字
  static Future<QuizItem> _generateDefinitionToKanji(String word, String definition) async {
    List<String> options = await _generateFakeKanjiOptions(word);
    options.add(word);
    options.shuffle();
    List<String> parsedDefinition = definition.split(RegExp(r'（[０-９]+）'));
    return QuizItem(
      question: ((parsedDefinition[_random.nextInt(parsedDefinition.length)]).split('▲'))[0],
      options: options,
      correctAnswer: word,
      type: 'definition_to_kanji',
    );
  }

  // 生成假的假名选项
  static Future<List<String>> _generateFakeKanaOptions(String correctKana) async {
    List<String> options = [];
    while (options.length < 3) {
      String randomWord = await _getRandomWord();
      List<Map<String, dynamic>> lookupResult = await TbLookup.lookup(randomWord);
      if (lookupResult.isNotEmpty) {
        String kana = lookupResult[0]['kana'];
        if (kana != correctKana && !options.contains(kana)) {
          options.add(kana);
        }
      }
    }
    return options;
  }

  // 生成假的汉字选项
  static Future<List<String>> _generateFakeKanjiOptions(String correctKanji) async {
    List<String> options = [];
    while (options.length < 3) {
      String randomWord = await _getRandomWord();
      if (randomWord != correctKanji && !options.contains(randomWord)) {
        options.add(randomWord);
      }
    }
    return options;
  }

  // 生成假的释义选项
  static Future<List<String>> _generateFakeDefinitions(String correctDefinition) async {
    List<String> options = [];
    while (options.length < 3) {
      String randomWord = await _getRandomWord();
      List<Map<String, dynamic>> lookupResult = await TbLookup.lookup(randomWord);
      if (lookupResult.isNotEmpty) {
        String definition = lookupResult[0]['definition'];
        if (definition != correctDefinition && !options.contains(definition)) {
          List<String> parsedDefinition = definition.split(RegExp(r'（[０-９]+）'));
          options.add(((parsedDefinition[_random.nextInt(parsedDefinition.length)]).split('▲'))[0]);
        }
      }
    }
    return options;
  }

  // 从词汇列表中随机获取一个词
  static Future<String> _getRandomWord() async {
    List<String> allWords = [];
    QzUtil.jlptWords.forEach((level, words) {
      allWords.addAll(words);
    });
    return allWords[Random().nextInt(allWords.length)];
  }

}
