import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// PathSaathi AI — Speech Service
/// Handles Speech-to-Text (STT) and Text-to-Speech (TTS)
/// with support for Indian regional languages.

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  // Language code mappings: app language code → BCP-47 locale
  static const Map<String, String> _speechLocales = {
    'en': 'en-IN',
    'hi': 'hi-IN',
    'mr': 'mr-IN',
    'bn': 'bn-IN',
    'te': 'te-IN',
    'ta': 'ta-IN',
    'gu': 'gu-IN',
    'kn': 'kn-IN',
    'ml': 'ml-IN',
    'pa': 'pa-IN',
    'or': 'or-IN',
  };

  // TTS language mappings
  static const Map<String, String> _ttsLanguages = {
    'en': 'en-IN',
    'hi': 'hi-IN',
    'mr': 'mr-IN',
    'bn': 'bn-BD',
    'te': 'te-IN',
    'ta': 'ta-IN',
    'gu': 'gu-IN',
    'kn': 'kn-IN',
    'ml': 'ml-IN',
    'pa': 'pa-IN',
  };

  // ── Initialization ────────────────────────────────────────────────────────

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Initialize STT
    final sttAvailable = await _speechToText.initialize(
      onError: (error) {},
      onStatus: (status) {},
    );

    // Initialize TTS
    await _flutterTts.setSharedInstance(true);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setErrorHandler((_) {
      _isSpeaking = false;
    });

    _isInitialized = sttAvailable;
    return sttAvailable;
  }

  // ── Speech to Text ────────────────────────────────────────────────────────

  bool get isListening => _speechToText.isListening;
  bool get isAvailable => _speechToText.isAvailable;

  Future<void> startListening({
    required Function(String text) onResult,
    required Function() onListenComplete,
    String language = 'en',
    double confidence = 0.8,
  }) async {
    if (!_isInitialized) await initialize();

    final locale = _speechLocales[language] ?? 'en-IN';

    await _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        } else {
          onResult(result.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: locale,
        cancelOnError: true,
        partialResults: true,
        listenMode: ListenMode.confirmation,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  Future<void> cancelListening() async {
    await _speechToText.cancel();
  }

  /// Get available locales
  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) await initialize();
    return await _speechToText.locales();
  }

  // ── Text to Speech ────────────────────────────────────────────────────────

  Future<void> speak({
    required String text,
    String language = 'en',
    double rate = 0.5,
    double pitch = 1.0,
    double volume = 1.0,
  }) async {
    if (_isSpeaking) await stop();

    final ttsLanguage = _ttsLanguages[language] ?? 'en-IN';

    await _flutterTts.setLanguage(ttsLanguage);
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.setPitch(pitch);
    await _flutterTts.setVolume(volume);

    // Clean markdown formatting before speaking
    final cleanText = _cleanMarkdown(text);
    await _flutterTts.speak(cleanText);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  Future<void> pause() async {
    await _flutterTts.pause();
  }

  /// Speak lesson content with appropriate settings
  Future<void> speakLesson({
    required String content,
    required String language,
  }) async {
    await speak(
      text: content,
      language: language,
      rate: 0.45, // Slightly slower for learning
      pitch: 1.0,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _cleanMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'#{1,6}\s'), '') // Remove headings
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // Bold
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1') // Italic
        .replaceAll(RegExp(r'`(.*?)`'), r'$1') // Code
        .replaceAll(RegExp(r'\[([^\]]*)\]\([^\)]*\)'), r'$1') // Links
        .replaceAll(RegExp(r'^\s*[-*+]\s', multiLine: true), '') // Lists
        .replaceAll(RegExp(r'^\s*\d+\.\s', multiLine: true), '') // Num lists
        .replaceAll('\n\n', '. ')
        .replaceAll('\n', ' ')
        .trim();
  }

  void dispose() {
    _flutterTts.stop();
  }
}
