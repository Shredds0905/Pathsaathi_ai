import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/chat_message_model.dart';

/// PathSaathi AI — Gemini AI Service
/// Handles all AI interactions: chat, summarization, quiz generation,
/// translation, career guidance, and OCR explanation.

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = AppConstants.geminiModel;

  final String _apiKey;

  GeminiService({String? apiKey})
      : _apiKey = apiKey ?? AppConstants.geminiApiKey;

  // ── Core Generation Method ────────────────────────────────────────────────

  Future<String> _generateContent({
    required List<Map<String, dynamic>> contents,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async {
    final url =
        '$_baseUrl/models/$_model:generateContent?key=$_apiKey';

    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': contents,
            'generationConfig': {
              'temperature': temperature,
              'maxOutputTokens': maxTokens,
              'topP': 0.95,
            },
            'safetySettings': [
              {
                'category': 'HARM_CATEGORY_HARASSMENT',
                'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
              },
              {
                'category': 'HARM_CATEGORY_HATE_SPEECH',
                'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
              },
            ],
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates =
          data['candidates'] as List<dynamic>? ?? [];
      if (candidates.isNotEmpty) {
        final content =
            candidates[0]['content'] as Map<String, dynamic>? ?? {};
        final parts = content['parts'] as List<dynamic>? ?? [];
        if (parts.isNotEmpty) {
          return parts[0]['text'] as String? ?? '';
        }
      }
      throw Exception('Empty response from Gemini');
    } else {
      throw Exception(
          'Gemini API Error ${response.statusCode}: ${response.body}');
    }
  }

  // ── Chat ──────────────────────────────────────────────────────────────────

  /// Send a chat message and get AI response
  Future<String> chat({
    required List<ChatMessageModel> history,
    required String userMessage,
    required String language,
    String? subject,
  }) async {
    final systemPrompt = _buildSystemPrompt(language, subject);

    final contents = <Map<String, dynamic>>[
      {
        'role': 'user',
        'parts': [{'text': systemPrompt}],
      },
      {
        'role': 'model',
        'parts': [
          {
            'text':
                'Understood! I am PathSaathi AI, your personal learning assistant. I will help you in $language with clear, simple explanations using local examples. How can I help you today?'
          }
        ],
      },
      // Add chat history
      ...history
          .where((m) => !m.isLoading)
          .map((m) => {
                'role': m.isUser ? 'user' : 'model',
                'parts': [
                  {'text': m.content},
                ],
              }),
      // Add current message
      {
        'role': 'user',
        'parts': [{'text': userMessage}],
      },
    ];

    return _generateContent(contents: contents);
  }

  /// Chat with an image (for camera learning / OCR)
  Future<String> chatWithImage({
    required String userMessage,
    required String base64Image,
    required String language,
    String mimeType = 'image/jpeg',
  }) async {
    final systemPrompt = _buildSystemPrompt(language, null);

    final contents = [
      {
        'role': 'user',
        'parts': [
          {'text': systemPrompt},
          {
            'inlineData': {
              'mimeType': mimeType,
              'data': base64Image,
            }
          },
          {'text': userMessage},
        ],
      }
    ];

    return _generateContent(contents: contents, temperature: 0.3);
  }

  // ── Lesson Generation ─────────────────────────────────────────────────────

  /// Generate a complete lesson for a topic in specified language
  Future<Map<String, dynamic>> generateLesson({
    required String topic,
    required String subject,
    required String language,
    required String difficulty,
    int gradeLevel = 8,
  }) async {
    final prompt = '''
Generate a complete educational lesson for the following:
- Topic: $topic
- Subject: $subject  
- Language: $language (if not English, explain in that language but use English for technical terms)
- Difficulty: $difficulty
- Grade Level: $gradeLevel

Return a JSON object with:
{
  "title": "Lesson title",
  "content": "Full markdown lesson content with headings, examples, and local Indian analogies",
  "summary": "2-3 sentence summary",
  "keyPoints": ["point1", "point2", "point3", "point4", "point5"],
  "flashcards": [
    {"id": "f1", "front": "Question", "back": "Answer"},
    {"id": "f2", "front": "Question", "back": "Answer"}
  ],
  "durationMinutes": 15
}

Use simple language, real-world Indian examples (chai, roti, cricket, festivals etc), and analogies that rural/first-generation learners can relate to.
Return ONLY the JSON, no other text.
''';

    final response = await _generateContent(
      contents: [
        {
          'role': 'user',
          'parts': [{'text': prompt}],
        }
      ],
      temperature: 0.4,
      maxTokens: 4096,
    );

    try {
      // Extract JSON from response (handle markdown code blocks)
      var jsonStr = response.trim();
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
      }
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return {
        'title': topic,
        'content': response,
        'summary': 'AI-generated lesson on $topic',
        'keyPoints': [],
        'flashcards': [],
        'durationMinutes': 15,
      };
    }
  }

  // ── Quiz Generation ───────────────────────────────────────────────────────

  /// Generate quiz questions for a lesson/topic
  Future<List<Map<String, dynamic>>> generateQuiz({
    required String topic,
    required String content,
    required String language,
    required String difficulty,
    int numQuestions = 5,
  }) async {
    final prompt = '''
Generate $numQuestions quiz questions for the following topic:
Topic: $topic
Content: ${content.substring(0, content.length.clamp(0, 1000))}
Language: $language
Difficulty: $difficulty

Return a JSON array of questions:
[
  {
    "id": "q1",
    "question": "Question text",
    "type": "mcq",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctIndex": 0,
    "explanation": "Why this is correct",
    "points": 10
  }
]

Mix MCQ and true/false questions. Keep explanations simple and educational.
Return ONLY the JSON array, no other text.
''';

    final response = await _generateContent(
      contents: [
        {
          'role': 'user',
          'parts': [{'text': prompt}],
        }
      ],
      temperature: 0.3,
    );

    try {
      var jsonStr = response.trim();
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
      }
      return List<Map<String, dynamic>>.from(
          jsonDecode(jsonStr) as List);
    } catch (_) {
      return [];
    }
  }

  // ── Summary ───────────────────────────────────────────────────────────────

  /// Summarize content in specified language
  Future<String> summarize({
    required String content,
    required String language,
    int maxPoints = 5,
  }) async {
    final prompt = '''
Summarize the following content in $language with exactly $maxPoints key bullet points.
Use simple language that a student can understand.
Format as a numbered list.

Content: $content
''';

    return _generateContent(
      contents: [
        {
          'role': 'user',
          'parts': [{'text': prompt}],
        }
      ],
      temperature: 0.3,
    );
  }

  // ── Translation ───────────────────────────────────────────────────────────

  /// Translate educational content to target language
  Future<String> translate({
    required String content,
    required String targetLanguage,
    bool preserveFormatting = true,
  }) async {
    final prompt = '''
Translate the following educational content to $targetLanguage.
${preserveFormatting ? 'Preserve markdown formatting (headings, bold, lists).' : ''}
Keep technical/scientific terms in English but explain them in $targetLanguage.
Make the translation natural and easy to understand for students.

Content:
$content
''';

    return _generateContent(
      contents: [
        {
          'role': 'user',
          'parts': [{'text': prompt}],
        }
      ],
      temperature: 0.2,
    );
  }

  // ── Career Guidance ───────────────────────────────────────────────────────

  /// Generate career recommendations based on student profile
  Future<String> generateCareerGuidance({
    required List<String> interests,
    required String education,
    required String marksRange,
    required List<String> skills,
    required String financialBackground,
    required String language,
    required String location,
  }) async {
    final prompt = '''
You are a career counsellor helping Indian students, especially from rural, first-generation learner, and economically weaker backgrounds.

Student Profile:
- Interests: ${interests.join(', ')}
- Education Level: $education
- Marks/Grade Range: $marksRange
- Current Skills: ${skills.join(', ')}
- Financial Background: $financialBackground
- Location: $location
- Preferred Language: $language

Please provide:
1. **Top 3 Career Options** that suit this student (with match %, salary range, steps to get there)
2. **Free/Low-cost Courses** available online (SWAYAM, NPTEL, Coursera free tier)
3. **Government Scholarships** they can apply for (NSP, state scholarships, etc.)
4. **Government Skill Schemes** (PMKVY, NAPS, Digital India programs)
5. **Inspiring Role Models** from similar backgrounds who succeeded
6. **6-month Roadmap** to start their career journey

Be encouraging, realistic, and specific to the Indian context.
Reply in $language.
''';

    return _generateContent(
      contents: [
        {
          'role': 'user',
          'parts': [{'text': prompt}],
        }
      ],
      temperature: 0.6,
      maxTokens: 3000,
    );
  }

  // ── OCR Explanation ───────────────────────────────────────────────────────

  /// Explain extracted text from textbook image
  Future<String> explainTextbookContent({
    required String extractedText,
    required String language,
    String? subject,
  }) async {
    final prompt = '''
A student photographed a page from their textbook. Here is the extracted text:

"$extractedText"

Please:
1. Explain the key concepts in simple words in $language
2. Give real-life examples that an Indian student can relate to
3. List the most important points to remember
4. Create 2-3 practice questions based on this content

${subject != null ? 'Subject: $subject' : ''}
Keep your explanation friendly and encouraging.
''';

    return _generateContent(
      contents: [
        {
          'role': 'user',
          'parts': [{'text': prompt}],
        }
      ],
      temperature: 0.5,
    );
  }

  // ── Homework Generation ───────────────────────────────────────────────────

  /// Generate homework assignment for a lesson
  Future<String> generateHomework({
    required String lessonTitle,
    required String subject,
    required String language,
    required String difficulty,
    int numQuestions = 5,
  }) async {
    final prompt = '''
Create a homework assignment for:
Lesson: $lessonTitle
Subject: $subject
Language: $language
Difficulty: $difficulty

Include:
1. $numQuestions practice problems (mix of easy, medium, hard)
2. One creative/application question
3. A "Think About It" reflection question

Format nicely with question numbers.
Keep it appropriate for the student's level.
''';

    return _generateContent(
      contents: [
        {
          'role': 'user',
          'parts': [{'text': prompt}],
        }
      ],
      temperature: 0.5,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _buildSystemPrompt(String language, String? subject) {
    final languageInstruction = language == 'en'
        ? 'Respond in clear, simple English.'
        : 'Respond primarily in $language. For scientific/technical terms, use the English term and explain it in $language.';

    final subjectHint =
        subject != null ? 'The student is studying $subject. ' : '';

    return '''
You are PathSaathi AI, a friendly and encouraging AI learning assistant designed specifically for Indian students, including:
- First-generation learners
- Rural students
- Government school students
- School dropouts returning to education
- Working professionals upskilling

Your teaching style:
- Use simple, clear language
- Always use Indian examples (cricket, festivals, food, farming, local stories)
- Be encouraging and never make students feel bad for not knowing something
- Break complex concepts into small, digestible parts
- Use analogies from everyday Indian life
- $languageInstruction
- ${subjectHint}Format responses clearly with headings and bullet points when helpful
- Always end with "Hope this helps! 😊 Ask me anything else."
''';
  }

  /// Get AI-suggested follow-up questions
  Future<List<String>> getSuggestedQuestions({
    required String lastMessage,
    required String subject,
    required String language,
  }) async {
    final prompt = '''
Based on this student's question about $subject: "$lastMessage"

Suggest 3 natural follow-up questions a student might ask next.
Return as a JSON array of strings: ["question1", "question2", "question3"]
Keep questions simple and in $language.
Return ONLY the JSON array.
''';

    try {
      final response = await _generateContent(
        contents: [
          {
            'role': 'user',
            'parts': [{'text': prompt}],
          }
        ],
        temperature: 0.7,
        maxTokens: 200,
      );
      var jsonStr = response.trim();
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
      }
      return List<String>.from(jsonDecode(jsonStr) as List);
    } catch (_) {
      return [
        'Can you explain this more simply?',
        'Give me an example',
        'Create a quiz on this topic',
      ];
    }
  }
}
