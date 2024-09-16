import 'dart:math';
import 'package:flutter/material.dart';
import '../modules/qzutil.dart';

class QuizView extends StatefulWidget {
  const QuizView({super.key});

  @override
  _QuizViewState createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  final _random = Random();
  List<String> _wordsToLearn = [];
  int _currentWordIndex = 0;
  late String _currentWord;
  late QuizItem _currentQuizItem;
  bool _isLoading = true;
  bool _showResult = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    await QzUtil.init();
    _wordsToLearn = QzUtil.getUnlearnedWords();
    _currentWordIndex = 0;
    _loadNextQuizItem();
  }

  Future<void> _loadNextQuizItem() async {
    if (_currentWordIndex >= _wordsToLearn.length) {
      // 所有词汇都已完成
      setState(() {
        _isLoading = false;
      });
      return;
    }

    var currentIndex = _currentWordIndex+_random.nextInt(20);
    while (QzUtil.progress[_wordsToLearn[currentIndex]] != null && QzUtil.progress[_wordsToLearn[currentIndex]]! >= 3){
      currentIndex = _currentWordIndex+_random.nextInt(20);
    }
    
    _currentWord = _wordsToLearn[currentIndex];
    _currentQuizItem = await QuizItem.generate(_currentWord);
    setState(() {
      _isLoading = false;
      _showResult = false;
    });
  }

  void _checkAnswer(String selectedOption) {
    setState(() {
      _isCorrect = selectedOption == _currentQuizItem.correctAnswer;
      _showResult = true;
    });
    if (_isCorrect) {
      // 更新背诵进度
      QzUtil.progress[_currentWord] = (QzUtil.progress[_currentWord] ?? 0) + 1;
      QzUtil.saveProgress();
      if (QzUtil.progress[_currentWord]! >= 3) {
        _currentWordIndex++;
      }
      Future.delayed(const Duration(seconds: 1), () {
        _loadNextQuizItem();
      });
    }else{
      Future.delayed(const Duration(seconds: 1), () {
        _loadNextQuizItem();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentWordIndex >= _wordsToLearn.length) {
      return const Center(
        child: Text(
          '恭喜！您已完成所有词汇的背诵。',
          style: TextStyle(fontSize: 24),
        ),
      );
    }

    return Center(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
            Text(
              _currentQuizItem.question,
              style: const TextStyle(
                fontSize: 36,
                color: Colors.black,
                fontFamily: 'NotoSerifJP',  // 使用 Noto Serif Japanese 字体
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 20),
          ..._currentQuizItem.options.map((option) {
            return ElevatedButton(
              onPressed: _showResult ? null : () => _checkAnswer(option),
              child: Text(option),
              style: ElevatedButton.styleFrom(
                backgroundColor: _showResult
                    ? option == _currentQuizItem.correctAnswer
                        ? Colors.green
                        : Colors.red
                    : null,
              ),
            );
          }),
          if (_showResult)
            Text(
              _isCorrect ? '回答正确！' : '回答错误！正确答案是：${_currentQuizItem.correctAnswer}',
              style: TextStyle(
                fontSize: 20,
                color: _isCorrect ? Colors.green : Colors.red,
              ),
            ),
          const SizedBox(height: 20),
          Text('当前词汇进度：${QzUtil.progress[_currentWord]??'0'}/3'),
        ],
      ),
    );
  }
}
