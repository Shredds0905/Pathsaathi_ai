import 'package:flutter/foundation.dart';
import '../models/quiz_model.dart';

/// PathSaathi AI — Quiz Provider
/// Manages the quiz session state machine.

enum QuizState { idle, inProgress, reviewing, completed }

class QuizProvider extends ChangeNotifier {
  QuizModel? _currentQuiz;
  int _currentQuestionIndex = 0;
  QuizState _state = QuizState.idle;
  final List<dynamic> _userAnswers = [];
  final List<bool> _answerResults = [];
  int _score = 0;
  int _xpEarned = 0;
  int _secondsElapsed = 0;
  bool _showExplanation = false;
  int? _selectedAnswerIndex;

  QuizModel? get currentQuiz => _currentQuiz;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuizState get state => _state;
  List<dynamic> get userAnswers => List.unmodifiable(_userAnswers);
  List<bool> get answerResults => List.unmodifiable(_answerResults);
  int get score => _score;
  int get xpEarned => _xpEarned;
  int get secondsElapsed => _secondsElapsed;
  bool get showExplanation => _showExplanation;
  int? get selectedAnswerIndex => _selectedAnswerIndex;

  // Current question
  QuizQuestion? get currentQuestion {
    if (_currentQuiz == null) return null;
    if (_currentQuestionIndex >= _currentQuiz!.questions.length) return null;
    return _currentQuiz!.questions[_currentQuestionIndex];
  }

  int get totalQuestions => _currentQuiz?.questions.length ?? 0;
  int get questionsAnswered => _userAnswers.length;
  bool get isLastQuestion =>
      _currentQuestionIndex == totalQuestions - 1;

  double get progressFraction =>
      totalQuestions > 0 ? (currentQuestionIndex + 1) / totalQuestions : 0;

  bool get hasAnsweredCurrent =>
      _userAnswers.length > _currentQuestionIndex;

  bool get isCurrentAnswerCorrect =>
      _answerResults.isNotEmpty ? _answerResults.last : false;

  // ── Start Quiz ────────────────────────────────────────────────────────────

  void startQuiz(QuizModel quiz) {
    _currentQuiz = quiz;
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _answerResults.clear();
    _score = 0;
    _xpEarned = 0;
    _secondsElapsed = 0;
    _state = QuizState.inProgress;
    _showExplanation = false;
    _selectedAnswerIndex = null;
    notifyListeners();
  }

  // ── Answer Question ───────────────────────────────────────────────────────

  void answerQuestion(dynamic answer) {
    if (_state != QuizState.inProgress) return;
    if (hasAnsweredCurrent) return;

    final question = currentQuestion;
    if (question == null) return;

    final isCorrect = question.checkAnswer(answer);

    _userAnswers.add(answer);
    _answerResults.add(isCorrect);

    if (isCorrect) {
      _score += question.points;
    }

    _showExplanation = true;
    notifyListeners();
  }

  void selectAnswer(int index) {
    if (hasAnsweredCurrent) return;
    _selectedAnswerIndex = index;
    notifyListeners();
  }

  void submitAnswer() {
    if (_selectedAnswerIndex != null) {
      answerQuestion(_selectedAnswerIndex);
    }
  }

  // ── Next Question ─────────────────────────────────────────────────────────

  void nextQuestion() {
    if (!hasAnsweredCurrent) return;

    _showExplanation = false;
    _selectedAnswerIndex = null;

    if (isLastQuestion) {
      _completeQuiz();
    } else {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  // ── Complete Quiz ─────────────────────────────────────────────────────────

  void _completeQuiz() {
    if (_currentQuiz == null) return;

    final correctCount = _answerResults.where((r) => r).length;
    final percent = correctCount / totalQuestions;

    // XP earned based on score
    _xpEarned = ((_currentQuiz!.xpReward * percent) * 1.0).toInt();

    _state = QuizState.completed;
    notifyListeners();
  }

  // ── Results ───────────────────────────────────────────────────────────────

  QuizResult get result {
    final correctAnswers = _answerResults.where((r) => r).length;
    return QuizResult(
      quizId: _currentQuiz?.id ?? '',
      userId: '',
      score: _score,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      timeTakenSeconds: _secondsElapsed,
      xpEarned: _xpEarned,
      completedAt: DateTime.now(),
      answerResults: List.from(_answerResults),
    );
  }

  // ── Timer ─────────────────────────────────────────────────────────────────

  void tickTimer() {
    if (_state == QuizState.inProgress) {
      _secondsElapsed++;
      notifyListeners();
    }
  }

  String get formattedTime {
    final minutes = _secondsElapsed ~/ 60;
    final seconds = _secondsElapsed % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void reset() {
    _currentQuiz = null;
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _answerResults.clear();
    _score = 0;
    _xpEarned = 0;
    _secondsElapsed = 0;
    _state = QuizState.idle;
    _showExplanation = false;
    notifyListeners();
  }

  void retakeQuiz() {
    if (_currentQuiz == null) return;
    startQuiz(_currentQuiz!);
  }
}
