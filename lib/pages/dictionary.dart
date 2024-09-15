import 'package:flutter/material.dart';

class DictionaryPage extends StatelessWidget {
  const DictionaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '辞书页面',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
