import 'package:flutter/material.dart';
import '../components/furigana.dart';  // 导入 FuriganaText 组件

// FuriganaText 和句子分隔符的展示
class InmView extends StatelessWidget {
  final List<List<FuriganaChar>> pageContent;  // 当前页显示的句子

  const InmView({
    super.key,
    required this.pageContent,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (var sentence in pageContent) ...[
          FuriganaText(furiganaChars: sentence),
          const SentenceSplitLine(),
        ],
      ],
    );
  }
}

class SentenceSplitLine extends StatelessWidget {
  const SentenceSplitLine({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 6), // 虚线距离下划线2px
      height: 1,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          const dashWidth = 5.0;
          const dashSpace = 3.0;
          final dashCount = (constraints.constrainWidth() / (dashWidth + dashSpace)).floor();
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
