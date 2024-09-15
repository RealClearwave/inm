import 'package:flutter/material.dart';

// FuriganaChar 类用于存储每个字符的信息
class FuriganaChar {
  final String kanji;  // 汉字
  final String? furigana;  // 平假名
  final bool underline;  // 是否有下划线
  final bool bold;  // 是否加粗
  final Color underlineColor; // 下划线颜色

  FuriganaChar({
    required this.kanji,
    this.furigana,
    this.underline = false,
    this.bold = false,
    this.underlineColor = const Color(0xFFFFC0CB), // 默认桃红色
  });
}

// 判断一个字符串中的每个字符是否为平假名或片假名
bool isAllKana(String text) {
  final kanaRegex = RegExp(r'^[\u3040-\u30FF]+$'); // 平假名和片假名的 Unicode 范围
  return kanaRegex.hasMatch(text);
}

// 将片假名转换为平假名的映射
String katakanaToHiragana(String katakana) {
  return katakana.replaceAllMapped(RegExp(r'[\u30A0-\u30FF]'), (match) {
    // Katakana Unicode 范围是 0x30A0-0x30FF, 对应的 Hiragana 范围是 0x3040-0x309F
    String katakanaChar = match.group(0)!;
    return String.fromCharCode(katakanaChar.codeUnitAt(0) - 0x60);
  });
}

// 自定义的下划线小部件，显示为圆角矩形
class UnderlineWidget extends StatelessWidget {
  final String kanji;
  final String? furigana;
  final bool underline;
  final bool bold;
  final Color underlineColor;

  const UnderlineWidget({
    super.key,
    required this.kanji,
    this.furigana,
    this.underline = false,
    this.bold = false,
    this.underlineColor = const Color(0xFFFFC0CB), // 默认桃红色
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (furigana != null && furigana != ' ')
          Text(
            furigana!,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'NotoSerifJP',  // 使用 Noto Serif Japanese 字体
            ),
          ),
        if (furigana == null || furigana == ' ')
          const SizedBox(height: 12),  // 如果没有 Furigana，保持一定的行高
        Stack(
          children: [
            Text(
              kanji,
              style: TextStyle(
                fontSize: 20,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
                fontFamily: 'NotoSerifJP',  // 使用 Noto Serif Japanese 字体
              ),
            ),
            if (underline)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 20, 
                  height: 4, 
                  decoration: BoxDecoration(
                    color: underlineColor.withOpacity(0.7), // 半透明的颜色
                    borderRadius: BorderRadius.circular(2), // 圆角矩形
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// FuriganaText 组件用于显示汉字和上标的平假名，支持滚动
class FuriganaText extends StatelessWidget {
  final List<FuriganaChar> furiganaChars;

  const FuriganaText({
    super.key,
    required this.furiganaChars,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(  // 添加滚动功能
      child: RichText(
        text: TextSpan(
          children: furiganaChars.map((furiganaChar) {

            // 判断是否需要显示 Furigana，如果是平假名或片假名的组合，则替换 Furigana 为空格
            String? furiganaToShow = furiganaChar.furigana;
            if (furiganaToShow != null && isAllKana(furiganaChar.kanji)) {
              furiganaToShow = ' '; // 如果是全假名，不标注 furigana，使用空格替代
            } else if (furiganaToShow != null) {
              furiganaToShow = katakanaToHiragana(furiganaToShow); // 将片假名转换为平假名
            }

            return WidgetSpan(
              child: UnderlineWidget(
                kanji: furiganaChar.kanji,
                furigana: furiganaToShow,
                underline: furiganaChar.underline,
                bold: furiganaChar.bold,
                underlineColor: furiganaChar.underlineColor,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
