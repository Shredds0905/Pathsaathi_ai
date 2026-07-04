/// PathSaathi AI — Lesson & Subject Models

class LessonModel {
  final String id;
  final String title;
  final String subject;
  final String subjectId;
  final String content;
  final String summary;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int durationMinutes;
  final String difficulty; // beginner | intermediate | advanced
  final String language;
  final List<String> tags;
  final List<FlashcardModel> flashcards;
  final List<String> keyPoints;
  final bool isDownloaded;
  final bool isCompleted;
  final int xpReward;
  final DateTime createdAt;
  final String createdBy; // teacher uid or 'system'

  const LessonModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.subjectId,
    required this.content,
    required this.summary,
    this.videoUrl,
    this.thumbnailUrl,
    this.durationMinutes = 10,
    this.difficulty = 'beginner',
    this.language = 'en',
    this.tags = const [],
    this.flashcards = const [],
    this.keyPoints = const [],
    this.isDownloaded = false,
    this.isCompleted = false,
    this.xpReward = 50,
    required this.createdAt,
    this.createdBy = 'system',
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      videoUrl: json['videoUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 10,
      difficulty: json['difficulty'] as String? ?? 'beginner',
      language: json['language'] as String? ?? 'en',
      tags: List<String>.from(json['tags'] as List? ?? []),
      flashcards: (json['flashcards'] as List? ?? [])
          .map((f) => FlashcardModel.fromJson(f as Map<String, dynamic>))
          .toList(),
      keyPoints: List<String>.from(json['keyPoints'] as List? ?? []),
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 50,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      createdBy: json['createdBy'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'subjectId': subjectId,
      'content': content,
      'summary': summary,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'durationMinutes': durationMinutes,
      'difficulty': difficulty,
      'language': language,
      'tags': tags,
      'flashcards': flashcards.map((f) => f.toJson()).toList(),
      'keyPoints': keyPoints,
      'isDownloaded': isDownloaded,
      'isCompleted': isCompleted,
      'xpReward': xpReward,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  LessonModel copyWith({
    bool? isDownloaded,
    bool? isCompleted,
    String? language,
    List<FlashcardModel>? flashcards,
    String? summary,
    List<String>? keyPoints,
  }) {
    return LessonModel(
      id: id,
      title: title,
      subject: subject,
      subjectId: subjectId,
      content: content,
      summary: summary ?? this.summary,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      durationMinutes: durationMinutes,
      difficulty: difficulty,
      language: language ?? this.language,
      tags: tags,
      flashcards: flashcards ?? this.flashcards,
      keyPoints: keyPoints ?? this.keyPoints,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isCompleted: isCompleted ?? this.isCompleted,
      xpReward: xpReward,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}

class FlashcardModel {
  final String id;
  final String front;
  final String back;
  final String? imageUrl;

  const FlashcardModel({
    required this.id,
    required this.front,
    required this.back,
    this.imageUrl,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] as String? ?? '',
      front: json['front'] as String? ?? '',
      back: json['back'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'front': front,
        'back': back,
        'imageUrl': imageUrl,
      };
}

/// Static sample lessons for offline/demo use
class SampleLessons {
  static List<LessonModel> get all => [
        LessonModel(
          id: 'lesson_math_001',
          title: 'Introduction to Fractions',
          subject: 'Mathematics',
          subjectId: 'math',
          content: '''
# Introduction to Fractions

A **fraction** represents a part of a whole. It consists of two numbers:
- **Numerator** (top number): how many parts we have
- **Denominator** (bottom number): total number of equal parts

## Types of Fractions
- **Proper fraction**: numerator < denominator (e.g., 3/4)
- **Improper fraction**: numerator ≥ denominator (e.g., 7/4)
- **Mixed number**: whole number + proper fraction (e.g., 1¾)

## Real-World Example
If you cut a roti into 4 equal pieces and eat 3 pieces, you have eaten 3/4 of the roti.

## Adding Fractions
Same denominator: Add numerators, keep denominator
1/4 + 2/4 = 3/4

Different denominator: Find LCM first
1/2 + 1/3 = 3/6 + 2/6 = 5/6
''',
          summary:
              'Fractions represent parts of a whole. Learn about numerators, denominators, types of fractions, and basic operations.',
          durationMinutes: 15,
          difficulty: 'beginner',
          keyPoints: [
            'Fraction = part of a whole',
            'Numerator = parts we have, Denominator = total parts',
            'Proper, Improper, and Mixed fractions',
            'Adding fractions with same and different denominators',
          ],
          flashcards: [
            FlashcardModel(
                id: 'f1',
                front: 'What is a fraction?',
                back: 'A fraction represents a part of a whole, written as a/b'),
            FlashcardModel(
                id: 'f2',
                front: 'What is the numerator?',
                back:
                    'The top number in a fraction — how many parts we have'),
            FlashcardModel(
                id: 'f3',
                front: 'What is the denominator?',
                back:
                    'The bottom number in a fraction — total number of equal parts'),
          ],
          xpReward: 50,
          createdAt: DateTime(2024, 1, 1),
        ),
        LessonModel(
          id: 'lesson_sci_001',
          title: 'Photosynthesis — How Plants Make Food',
          subject: 'Science',
          subjectId: 'science',
          content: '''
# Photosynthesis

Photosynthesis is the process by which plants use sunlight, water, and carbon dioxide to produce oxygen and energy (glucose).

## The Simple Equation
**6CO₂ + 6H₂O + Light Energy → C₆H₁₂O₆ + 6O₂**
(Carbon dioxide + Water + Light → Glucose + Oxygen)

## Where does it happen?
In the **chloroplasts** — green structures in plant cells containing **chlorophyll** (the green pigment that absorbs sunlight).

## Two Stages
1. **Light Reaction** (in thylakoids): Light → ATP + NADPH
2. **Calvin Cycle** (in stroma): CO₂ → Glucose using ATP + NADPH

## Why is it important?
- Produces oxygen we breathe
- Forms the base of all food chains
- Converts solar energy to chemical energy
''',
          summary:
              'Photosynthesis is how plants make food using sunlight, water, and CO₂, producing glucose and oxygen.',
          durationMinutes: 20,
          difficulty: 'intermediate',
          keyPoints: [
            'Plants use sunlight, water, CO₂ to make glucose',
            'Happens in chloroplasts (chlorophyll)',
            'Two stages: Light Reaction and Calvin Cycle',
            'Produces oxygen as a by-product',
          ],
          flashcards: [
            FlashcardModel(
                id: 'f1',
                front: 'What is photosynthesis?',
                back:
                    'Process by which plants make food using sunlight, water, and CO₂'),
            FlashcardModel(
                id: 'f2',
                front: 'Where does photosynthesis occur?',
                back: 'In chloroplasts, which contain chlorophyll'),
          ],
          xpReward: 75,
          createdAt: DateTime(2024, 1, 2),
        ),
      ];
}
