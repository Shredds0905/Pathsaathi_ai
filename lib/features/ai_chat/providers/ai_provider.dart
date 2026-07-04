import 'package:flutter/foundation.dart';
import '../../../models/chat_message_model.dart';
import '../../../services/gemini_service.dart';

/// PathSaathi AI — AI Provider
/// Manages AI chat state, message history, and suggested questions.

class AIProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();

  final List<ChatMessageModel> _messages = [];
  List<String> _suggestedQuestions = [
    'Explain fractions to me in simple words',
    'What is photosynthesis?',
    'Help me with my homework',
    'Tell me about career options after 12th',
  ];
  bool _isGenerating = false;
  String _currentLanguage = 'en';
  String? _currentSubject;
  String? _errorMessage;

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  List<String> get suggestedQuestions =>
      List.unmodifiable(_suggestedQuestions);
  bool get isGenerating => _isGenerating;
  String get currentLanguage => _currentLanguage;
  String? get currentSubject => _currentSubject;
  String? get errorMessage => _errorMessage;
  bool get hasMessages => _messages.isNotEmpty;

  // ── Initialize ────────────────────────────────────────────────────────────

  void initialize({String? language, String? subject}) {
    _currentLanguage = language ?? 'en';
    _currentSubject = subject;

    if (_messages.isEmpty) {
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    final welcomeText = _currentLanguage == 'hi'
        ? '👋 नमस्ते! मैं PathSaathi AI हूं। आप मुझसे कोई भी सवाल पूछ सकते हैं। मैं आपकी पढ़ाई में मदद करने के लिए यहाँ हूं! 😊'
        : _currentLanguage == 'mr'
            ? '👋 नमस्कार! मी PathSaathi AI आहे। तुम्ही मला कोणताही प्रश्न विचारू शकता. मी तुमच्या शिक्षणासाठी येथे आहे! 😊'
            : '👋 Hello! I\'m PathSaathi AI, your personal learning assistant.\n\nI can help you:\n• Understand any topic in your language\n• Generate notes and summaries\n• Create practice quizzes\n• Guide your career path\n\nWhat would you like to learn today? 😊';

    _messages.add(ChatMessageModel.assistant(
      content: welcomeText,
      language: _currentLanguage,
    ));
  }

  // ── Send Message ──────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isGenerating) return;

    // Add user message
    final userMsg = ChatMessageModel.user(
      content: text.trim(),
      language: _currentLanguage,
    );
    _messages.add(userMsg);

    // Add loading placeholder
    final loadingMsg = ChatMessageModel.loading();
    _messages.add(loadingMsg);

    _isGenerating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get response from Gemini
      final history = _messages
          .where((m) => !m.isLoading && m.id != loadingMsg.id)
          .toList();

      final response = await _geminiService.chat(
        history: history.length > 20
            ? history.sublist(history.length - 20)
            : history,
        userMessage: text.trim(),
        language: _currentLanguage,
        subject: _currentSubject,
      );

      // Remove loading message and add real response
      _messages.remove(loadingMsg);
      _messages.add(ChatMessageModel.assistant(
        content: response,
        language: _currentLanguage,
      ));

      // Update suggested questions based on the conversation
      _updateSuggestedQuestions(text.trim());
    } catch (e) {
      _messages.remove(loadingMsg);
      _errorMessage = 'Failed to get AI response. Please try again.';

      // Add error message in chat
      _messages.add(ChatMessageModel.assistant(
        content:
            '😔 I\'m having trouble connecting right now. Please check your internet connection and try again.\n\nIf you\'re offline, I can still help you with downloaded lessons!',
        language: _currentLanguage,
      ));
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  // ── Send Image Message ────────────────────────────────────────────────────

  Future<void> sendImageMessage({
    required String base64Image,
    required String userQuestion,
  }) async {
    if (_isGenerating) return;

    final userMsg = ChatMessageModel.user(
      content: userQuestion.isEmpty
          ? 'Please explain what is in this image'
          : userQuestion,
      language: _currentLanguage,
    );
    _messages.add(userMsg);

    final loadingMsg = ChatMessageModel.loading();
    _messages.add(loadingMsg);

    _isGenerating = true;
    notifyListeners();

    try {
      final response = await _geminiService.chatWithImage(
        userMessage: userQuestion.isEmpty
            ? 'Explain this textbook content in simple words. Give examples a student can understand.'
            : userQuestion,
        base64Image: base64Image,
        language: _currentLanguage,
      );

      _messages.remove(loadingMsg);
      _messages.add(ChatMessageModel.assistant(
        content: response,
        language: _currentLanguage,
      ));
    } catch (e) {
      _messages.remove(loadingMsg);
      _messages.add(ChatMessageModel.assistant(
        content: '😔 Could not analyze the image. Please try again.',
        language: _currentLanguage,
      ));
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  // ── Suggested Questions ───────────────────────────────────────────────────

  Future<void> _updateSuggestedQuestions(String lastMessage) async {
    try {
      final questions = await _geminiService.getSuggestedQuestions(
        lastMessage: lastMessage,
        subject: _currentSubject ?? 'general',
        language: _currentLanguage,
      );
      _suggestedQuestions = questions;
      notifyListeners();
    } catch (_) {
      // Keep existing suggestions on error
    }
  }

  // ── AI Tools ──────────────────────────────────────────────────────────────

  Future<void> generateSummary(String content) async {
    await sendMessage(
        'Please summarize this content: $content');
  }

  Future<void> generateQuiz(String topic) async {
    await sendMessage(
        'Create a 5-question quiz on: $topic');
  }

  Future<void> generateHomework(String lessonTitle) async {
    await sendMessage(
        'Create homework practice questions for: $lessonTitle');
  }

  Future<String> generateDirectResponse(String prompt) async {
    try {
      return await _geminiService.chat(
        history: [],
        userMessage: prompt,
        language: _currentLanguage,
      );
    } catch (e) {
      return 'Error generating response: $e';
    }
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  void clearChat() {
    _messages.clear();
    _addWelcomeMessage();
    _suggestedQuestions = [
      'Explain fractions to me in simple words',
      'What is photosynthesis?',
      'Help me with my homework',
      'Tell me about career options after 12th',
    ];
    notifyListeners();
  }

  // ── Language ──────────────────────────────────────────────────────────────

  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    notifyListeners();
  }

  void setSubject(String? subject) {
    _currentSubject = subject;
    notifyListeners();
  }
}
