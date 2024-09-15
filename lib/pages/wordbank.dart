import 'package:flutter/material.dart';

class WordBankPage extends StatelessWidget {
  const WordBankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '背词页面',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
