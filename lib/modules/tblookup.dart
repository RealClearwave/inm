import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';  // 添加SharedPreferences支持

class TbLookup {
  static Future<List<Map<String, dynamic>>> lookup(String query) async {
    List<Map<String, dynamic>> exactMatches = [];  // 完全匹配结果
    List<Map<String, dynamic>> partialMatches = [];  // 部分匹配结果

    int partialCount = 0;

    // 加载所有 JSON 文件
    for (int i = 1; i <= 8; i++) {
      String data = await rootBundle.loadString('assets/dict/term_bank_$i.json');  // 更新资源路径
      List<dynamic> jsonData = json.decode(data);

      for (var entry in jsonData) {
        String word = entry[0];  // 第一个字段为词语（汉字）
        String kana = entry[1];  // 第二个字段为假名
        String definition = entry[5][0];  // 定义在第6个字段

        // 判断是否查询汉字或假名
        if (word == query || kana == query) {
          // 完全匹配
          //print('查询：$query，词语：$word，假名：$kana');
          //print('processed definition: ${definition.replaceAll('～', word)}');
          exactMatches.add({
            'word': word,
            'kana': kana,
            'definition': definition.replaceAll('～', word),
          });
        } else {
          // 计算重合度，适用于部分匹配
          double wordSimilarity = _calculateSimilarity(word, query);
          double kanaSimilarity = _calculateSimilarity(kana, query);

          // 如果匹配汉字或假名，且重合度达到标准，加入部分匹配结果
          if ((wordSimilarity >= 0.5 || kanaSimilarity >= 0.5) && partialCount < 10) {
            //print('查询：$query，词语：$word，假名：$kana');
            //print('processed definition: ${definition.replaceAll('～', word)}');
            partialMatches.add({
              'word': word,
              'kana': kana,
              'definition': definition.replaceAll('～', word),
              'similarity': wordSimilarity > kanaSimilarity ? wordSimilarity : kanaSimilarity,
            });
            partialCount++;
          }
        }
      }
    }

    // 如果有完全匹配，返回完全匹配的结果，不显示部分匹配
    if (exactMatches.isNotEmpty) {
      return exactMatches;
    }

    // 对部分匹配结果按重合度排序
    partialMatches.sort((a, b) => (b['similarity'] as double).compareTo(a['similarity'] as double));

    // 返回部分匹配的结果
    return partialMatches;
  }

  // 判断两个字符串的重合度，返回0到1之间的值
  static double _calculateSimilarity(String word, String query) {
    Set<String> wordSet = word.split('').toSet();  // 将词语的每个字符转为集合
    Set<String> querySet = query.split('').toSet();  // 将查询的每个字符转为集合

    int intersectionSize = wordSet.intersection(querySet).length;  // 交集的大小

    return intersectionSize / querySet.length;
  }

  // 收藏单词功能
  static Future<void> addToFavorites(String word) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    if (!favorites.contains(word)) {
      favorites.add(word);
      await prefs.setStringList('favorites', favorites);
    }
  }

  // 获取收藏单词列表
  static Future<List<String>> getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorites') ?? [];
  }

  // 从收藏单词中移除
  static Future<void> removeFromFavorites(String word) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    if (favorites.contains(word)) {
      favorites.remove(word);
      await prefs.setStringList('favorites', favorites);
    }
  }
}
