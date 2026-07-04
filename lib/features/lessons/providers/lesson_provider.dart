import 'package:flutter/foundation.dart';
import '../../../models/lesson_model.dart';
import '../../../models/progress_model.dart';
import '../../../services/firestore_service.dart';
import '../../../config/constants.dart';

/// PathSaathi AI — Lesson Provider

class LessonProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  final Map<String, List<LessonModel>> _lessonsBySubject = {};
  LessonModel? _currentLesson;
  bool _isLoading = false;
  String? _errorMessage;

  List<LessonModel>? getLessonsForSubject(String subjectId) =>
      _lessonsBySubject[subjectId];

  LessonModel? get currentLesson => _currentLesson;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load sample lessons from local data (works offline)
  List<LessonModel> get sampleLessons => SampleLessons.all;

  Future<void> loadLessons(String subjectId) async {
    if (_lessonsBySubject.containsKey(subjectId)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final lessons =
          await _firestoreService.getLessonsBySubject(subjectId);

      // Fall back to sample lessons if none in Firestore
      if (lessons.isEmpty) {
        _lessonsBySubject[subjectId] = SampleLessons.all
            .where((l) => l.subjectId == subjectId)
            .toList();
      } else {
        _lessonsBySubject[subjectId] = lessons;
      }
    } catch (e) {
      // On error, use sample lessons (offline fallback)
      _lessonsBySubject[subjectId] = SampleLessons.all
          .where((l) => l.subjectId == subjectId)
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentLesson(LessonModel lesson) {
    _currentLesson = lesson;
    notifyListeners();
  }

  void markCurrentLessonComplete() {
    if (_currentLesson == null) return;
    _currentLesson = _currentLesson!.copyWith(isCompleted: true);
    notifyListeners();
  }

  List<LessonModel> getAllLessons() {
    return _lessonsBySubject.values.expand((l) => l).toList();
  }

  List<LessonModel> getRecommended(List<String> weakSubjects) {
    if (weakSubjects.isEmpty) return sampleLessons.take(3).toList();
    return sampleLessons
        .where((l) => weakSubjects.contains(l.subjectId))
        .take(5)
        .toList();
  }
}

/// PathSaathi AI — Progress Provider

class ProgressProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  ProgressModel? _progress;
  bool _isLoading = false;

  ProgressModel? get progress => _progress;
  bool get isLoading => _isLoading;

  int get totalXp => _progress?.totalXp ?? 0;
  int get level => _progress?.level ?? 1;
  int get streak => _progress?.currentStreak ?? 0;
  double get levelProgress => _progress?.levelProgress ?? 0;
  int get lessonsCompleted => _progress?.totalLessonsCompleted ?? 0;
  int get quizzesCompleted => _progress?.totalQuizzesCompleted ?? 0;

  Future<void> loadProgress(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      _progress = await _firestoreService.getProgress(uid) ??
          ProgressModel.initial(uid);
    } catch (_) {
      _progress = ProgressModel.initial(uid);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addXp(String uid, int xp) async {
    if (_progress == null) return;

    final newXp = _progress!.totalXp + xp;
    final newLevel = (newXp ~/ 500) + 1;

    _progress = ProgressModel(
      userId: _progress!.userId,
      subjects: _progress!.subjects,
      totalXp: newXp,
      level: newLevel,
      currentStreak: _progress!.currentStreak,
      longestStreak: _progress!.longestStreak,
      totalLessonsCompleted: _progress!.totalLessonsCompleted,
      totalQuizzesCompleted: _progress!.totalQuizzesCompleted,
      totalTimeSpentMinutes: _progress!.totalTimeSpentMinutes,
      earnedBadgeIds: _progress!.earnedBadgeIds,
      lastActiveAt: DateTime.now(),
      dailyXp: _progress!.dailyXp,
    );

    notifyListeners();
    await _firestoreService.updateProgress(_progress!);
  }

  Future<void> markLessonComplete(
    String uid,
    String lessonId,
    String subjectId,
    int xpEarned,
  ) async {
    await _firestoreService.markLessonComplete(
        uid, lessonId, subjectId, xpEarned);
    await loadProgress(uid);
  }

  List<double> get weeklyXpData {
    if (_progress == null) {
      // Sample data for demo/offline mode
      return [30, 0, 50, 20, 80, 45, 60];
    }

    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dateStr = day.toIso8601String().substring(0, 10);
      return (_progress!.dailyXp[dateStr] ?? 0).toDouble();
    });
  }
}

/// PathSaathi AI — Theme Provider

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}

/// PathSaathi AI — Language Provider

class LanguageProvider extends ChangeNotifier {
  String _currentLanguageCode = 'en';
  String _currentLanguageName = 'English';

  String get currentLanguageCode => _currentLanguageCode;
  String get currentLanguageName => _currentLanguageName;

  void setLanguage(String code, String name) {
    _currentLanguageCode = code;
    _currentLanguageName = name;
    notifyListeners();
  }

  Map<String, String>? get currentLanguageMap {
    return AppConstants.supportedLanguages.firstWhere(
      (l) => l['code'] == _currentLanguageCode,
      orElse: () => {'code': 'en', 'name': 'English', 'native': 'English'},
    );
  }
}

/// PathSaathi AI — Career Provider

class CareerProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _careerGuidance;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get careerGuidance => _careerGuidance;
  String? get errorMessage => _errorMessage;

  void setGuidance(String guidance) {
    _careerGuidance = guidance;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void clear() {
    _careerGuidance = null;
    _errorMessage = null;
    notifyListeners();
  }
}
