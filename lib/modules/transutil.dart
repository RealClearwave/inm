// lib/modules/transutil.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TransUtil {
  // 单例模式
  static final TransUtil _instance = TransUtil._internal();
  factory TransUtil() => _instance;
  
  TransUtil._internal();

  String apiUrl = ''; // 翻译 API 的 URL
  bool isTranslationEnabled = true; // 是否启用翻译

  // 初始化
  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiUrl = prefs.getString('translationApiUrl') ?? 
    'https://mozhi.pussthecat.org/api/translate?engine=deepl&from=ja&to=zh&text=';
    isTranslationEnabled = prefs.getBool('isTranslationEnabled') ?? true;
    //print('翻译API：$apiUrl, 启用翻译：$isTranslationEnabled');
  }

  // 设置翻译 API 的 URL
  Future<void> setApiUrl(String url) async{
    apiUrl = url;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('translationApiUrl', url);
  }

  // 设置是否启用翻译
  Future<void> setTranslationEnabled(bool enabled) async{
    isTranslationEnabled = enabled;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isTranslationEnabled', enabled);
  }

  // 翻译文本
  Future<String> translate(String text) async {
    if (!isTranslationEnabled || apiUrl.isEmpty) {
      return '';
    }

    // 对文本进行 URL 编码
    final encodedText = Uri.encodeComponent(text);

    // 构建完整的请求 URL
    final url = '$apiUrl$encodedText';
    //print('翻译请求：$url');
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // 假设 API 返回的 JSON 格式为：{"translation": "翻译后的文本"}
        final data = json.decode(response.body);
        final result = utf8.decode(data['translated-text'].codeUnits);
        //print('翻译结果：$result');
        return result;
      } else {
        //print('翻译请求失败：${response.statusCode}');
        return '';
      }
    } catch (e) {
      //print('翻译异常：$e');
      return '';
    }
  }
}
