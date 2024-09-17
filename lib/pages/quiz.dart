import 'package:flutter/material.dart';
import '../components/quizview.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('暗記'),
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Colors.pink.shade300,
      ),
      body: const QuizView(),
    );
  }
}
