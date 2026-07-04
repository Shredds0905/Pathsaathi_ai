/// PathSaathi AI — App Constants
/// Replace API key placeholders with your actual keys before running.

class AppConstants {
  AppConstants._();

  // ── App Info ────────────────────────────────────────────────────────────
  static const bool useMockData = true;
  static const String appName = 'PathSaathi AI';
  static const String appTagline = 'Every Learner Deserves a Guide';
  static const String appVersion = '1.0.0';

  // ── API Keys (REPLACE BEFORE PRODUCTION) ───────────────────────────────
  /// Get your Gemini API key from https://aistudio.google.com/app/apikey
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';

  /// FastAPI backend base URL (update when deployed)
  static const String backendBaseUrl = 'http://localhost:8000';

  // ── Firebase Collections ────────────────────────────────────────────────
  static const String usersCollection = 'users';
  static const String lessonsCollection = 'lessons';
  static const String progressCollection = 'progress';
  static const String chatHistoryCollection = 'chat_history';
  static const String attendanceCollection = 'attendance';
  static const String quizCollection = 'quiz';
  static const String achievementsCollection = 'achievements';
  static const String badgesCollection = 'badges';
  static const String careerReportsCollection = 'career_reports';
  static const String notificationsCollection = 'notifications';

  // ── Gemini Model Config ─────────────────────────────────────────────────
  static const String geminiModel = 'gemini-2.0-flash';
  static const int maxTokens = 2048;
  static const double temperature = 0.7;

  // ── Gamification ────────────────────────────────────────────────────────
  static const int xpPerLesson = 50;
  static const int xpPerQuiz = 100;
  static const int xpPerStreak = 25;
  static const int xpPerLevel = 500;
  static const int coinsPerLesson = 10;
  static const int coinsPerQuiz = 20;

  // ── Offline Storage Keys ─────────────────────────────────────────────────
  static const String prefUserToken = 'user_token';
  static const String prefUserId = 'user_id';
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefSelectedLanguage = 'selected_language';
  static const String prefDarkMode = 'dark_mode';
  static const String prefUserRole = 'user_role';
  static const String prefRememberLogin = 'remember_login';

  // ── Hive Boxes ───────────────────────────────────────────────────────────
  static const String hiveBoxLessons = 'offline_lessons';
  static const String hiveBoxQuizzes = 'offline_quizzes';
  static const String hiveBoxChatHistory = 'offline_chat';
  static const String hiveBoxUserData = 'user_data';
  static const String hiveBoxProgress = 'offline_progress';

  // ── Supported Languages ──────────────────────────────────────────────────
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिंदी'},
    {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
    {'code': 'gu', 'name': 'Gujarati', 'native': 'ગુજરાતી'},
    {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
    {'code': 'ml', 'name': 'Malayalam', 'native': 'മലയാളം'},
    {'code': 'pa', 'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
    {'code': 'or', 'name': 'Odia', 'native': 'ଓଡ଼ିଆ'},
    {'code': 'as', 'name': 'Assamese', 'native': 'অসমীয়া'},
    {'code': 'ur', 'name': 'Urdu', 'native': 'اردو'},
    {'code': 'ks', 'name': 'Kashmiri', 'native': 'كٲشُر'},
    {'code': 'sd', 'name': 'Sindhi', 'native': 'سنڌي'},
    {'code': 'ne', 'name': 'Nepali', 'native': 'नेपाली'},
    {'code': 'sa', 'name': 'Sanskrit', 'native': 'संस्कृतम्'},
    {'code': 'mai', 'name': 'Maithili', 'native': 'मैथिली'},
    {'code': 'doi', 'name': 'Dogri', 'native': 'डोगरी'},
    {'code': 'mni', 'name': 'Manipuri', 'native': 'ꯃꯤꯇꯩ ꯂꯣꯟ'},
    {'code': 'sat', 'name': 'Santali', 'native': 'ᱥᱟᱱᱛᱟᱲᱤ'},
    {'code': 'kok', 'name': 'Konkani', 'native': 'कोंकणी'},
  ];

  // ── Subjects ─────────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> subjects = [
    {'id': 'math', 'name': 'Mathematics', 'icon': '📐', 'color': 0xFF6C5CE7},
    {'id': 'science', 'name': 'Science', 'icon': '🔬', 'color': 0xFF00B894},
    {'id': 'english', 'name': 'English', 'icon': '📚', 'color': 0xFF0984E3},
    {'id': 'history', 'name': 'History', 'icon': '🏛️', 'color': 0xFFE17055},
    {'id': 'geography', 'name': 'Geography', 'icon': '🌍', 'color': 0xFF00CEC9},
    {'id': 'computer', 'name': 'Computer Science', 'icon': '💻', 'color': 0xFFA29BFE},
    {'id': 'reasoning', 'name': 'Reasoning', 'icon': '🧠', 'color': 0xFFFF7675},
    {'id': 'gk', 'name': 'General Knowledge', 'icon': '🌟', 'color': 0xFFFDCB6E},
  ];

  // ── User Roles ────────────────────────────────────────────────────────────
  static const String roleStudent = 'student';
  static const String roleTeacher = 'teacher';
  static const String roleParent = 'parent';
  static const String roleGuest = 'guest';

  // ── Difficulty Levels ─────────────────────────────────────────────────────
  static const String difficultyBeginner = 'beginner';
  static const String difficultyIntermediate = 'intermediate';
  static const String difficultyAdvanced = 'advanced';
}
