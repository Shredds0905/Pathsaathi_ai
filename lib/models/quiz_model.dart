/// PathSaathi AI — Quiz Models

enum QuestionType { mcq, trueFalse, fillBlank, imageQuestion }

class QuizModel {
  final String id;
  final String title;
  final String subject;
  final String subjectId;
  final String? lessonId;
  final List<QuizQuestion> questions;
  final int timeLimitSeconds; // 0 = no limit
  final String difficulty;
  final int xpReward;
  final String language;
  final DateTime createdAt;

  const QuizModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.subjectId,
    this.lessonId,
    required this.questions,
    this.timeLimitSeconds = 0,
    this.difficulty = 'beginner',
    this.xpReward = 100,
    this.language = 'en',
    required this.createdAt,
  });

  int get totalQuestions => questions.length;

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? '',
      lessonId: json['lessonId'] as String?,
      questions: (json['questions'] as List? ?? [])
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      timeLimitSeconds: (json['timeLimitSeconds'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty'] as String? ?? 'beginner',
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 100,
      language: json['language'] as String? ?? 'en',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'subjectId': subjectId,
        'lessonId': lessonId,
        'questions': questions.map((q) => q.toJson()).toList(),
        'timeLimitSeconds': timeLimitSeconds,
        'difficulty': difficulty,
        'xpReward': xpReward,
        'language': language,
        'createdAt': createdAt.toIso8601String(),
      };
}

class QuizQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final List<String> options; // for MCQ / true-false
  final int correctIndex; // index into options or 0 for fill-blank
  final String correctAnswer; // for fill-blank
  final String explanation;
  final String? imageUrl;
  final int points;

  const QuizQuestion({
    required this.id,
    required this.question,
    this.type = QuestionType.mcq,
    this.options = const [],
    this.correctIndex = 0,
    this.correctAnswer = '',
    this.explanation = '',
    this.imageUrl,
    this.points = 10,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      type: QuestionType.values.firstWhere(
        (t) => t.name == (json['type'] as String? ?? 'mcq'),
        orElse: () => QuestionType.mcq,
      ),
      options: List<String>.from(json['options'] as List? ?? []),
      correctIndex: (json['correctIndex'] as num?)?.toInt() ?? 0,
      correctAnswer: json['correctAnswer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      points: (json['points'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'type': type.name,
        'options': options,
        'correctIndex': correctIndex,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'imageUrl': imageUrl,
        'points': points,
      };

  bool checkAnswer(dynamic userAnswer) {
    switch (type) {
      case QuestionType.mcq:
      case QuestionType.trueFalse:
        return userAnswer == correctIndex;
      case QuestionType.fillBlank:
        return (userAnswer as String)
            .trim()
            .toLowerCase()
            .contains(correctAnswer.trim().toLowerCase());
      case QuestionType.imageQuestion:
        return userAnswer == correctIndex;
    }
  }
}

/// Quiz session result
class QuizResult {
  final String quizId;
  final String userId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int timeTakenSeconds;
  final int xpEarned;
  final DateTime completedAt;
  final List<bool> answerResults;

  const QuizResult({
    required this.quizId,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeTakenSeconds,
    required this.xpEarned,
    required this.completedAt,
    required this.answerResults,
  });

  double get percentage => (correctAnswers / totalQuestions) * 100;
  bool get isPassed => percentage >= 60;

  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    return 'F';
  }
}

/// Sample quizzes
class SampleQuizzes {
  static List<QuizModel> get all => [
        QuizModel(
          id: 'quiz_math_001',
          title: 'Fractions Quiz',
          subject: 'Mathematics',
          subjectId: 'math',
          lessonId: 'lesson_math_001',
          timeLimitSeconds: 300,
          xpReward: 100,
          createdAt: DateTime(2024, 1, 1),
          questions: [
            const QuizQuestion(
              id: 'q1',
              question: 'What is 1/2 + 1/4?',
              type: QuestionType.mcq,
              options: ['1/2', '3/4', '2/4', '1/6'],
              correctIndex: 1,
              explanation:
                  '1/2 = 2/4, so 2/4 + 1/4 = 3/4',
              points: 10,
            ),
            const QuizQuestion(
              id: 'q2',
              question: 'A proper fraction has numerator LESS THAN denominator.',
              type: QuestionType.trueFalse,
              options: ['True', 'False'],
              correctIndex: 0,
              explanation:
                  'True! In a proper fraction, the numerator is always less than the denominator.',
              points: 10,
            ),
            const QuizQuestion(
              id: 'q3',
              question: 'In the fraction 3/7, the denominator is ___.',
              type: QuestionType.mcq,
              options: ['3', '7', '10', '4'],
              correctIndex: 1,
              explanation:
                  'The bottom number (7) is the denominator.',
              points: 10,
            ),
            const QuizQuestion(
              id: 'q4',
              question: 'Convert 7/4 to a mixed number.',
              type: QuestionType.mcq,
              options: ['1¾', '2¼', '1½', '2¾'],
              correctIndex: 0,
              explanation: '7 ÷ 4 = 1 remainder 3, so 7/4 = 1¾',
              points: 10,
            ),
            const QuizQuestion(
              id: 'q5',
              question: 'What is 3/5 of 25?',
              type: QuestionType.mcq,
              options: ['10', '12', '15', '20'],
              correctIndex: 2,
              explanation: '3/5 × 25 = 3 × 5 = 15',
              points: 10,
            ),
          ],
        ),
      ];
}
