import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../config/constants.dart';
import '../models/user_model.dart';
import '../models/lesson_model.dart';
import '../models/progress_model.dart';
import '../models/chat_message_model.dart';
import '../models/career_model.dart';

/// PathSaathi AI — Firestore Database Service
/// CRUD operations for all collections.

class FirestoreService {
  FirebaseFirestore? _dbInstance;
  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;
  
  FirebaseFirestore get _db {
    if (!_isFirebaseReady) throw Exception('Firebase not initialized');
    _dbInstance ??= FirebaseFirestore.instance;
    return _dbInstance!;
  }

  // ── User Operations ───────────────────────────────────────────────────────

  Future<void> createUser(UserModel user) async {
    try {
      await _db
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toJson());
    } catch (_) {}
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _db
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      return UserModel.fromJson({'uid': doc.id, ...doc.data()!});
    } catch (_) {
      return null; // Firebase unavailable — demo mode
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _db
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update(user.toJson());
    } catch (_) {}
  }

  Future<void> updateUserField(String uid, String field, dynamic value) async {
    try {
      await _db
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({field: value});
    } catch (_) {}
  }

  Future<void> deleteUser(String uid) async {
    try {
      final batch = _db.batch();
      batch.delete(
          _db.collection(AppConstants.usersCollection).doc(uid));
      await batch.commit();
    } catch (_) {}
  }

  Stream<UserModel?> userStream(String uid) {
    try {
      return _db
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .snapshots()
          .map((doc) {
        if (!doc.exists) return null;
        return UserModel.fromJson({'uid': doc.id, ...doc.data()!});
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  // ── Lesson Operations ─────────────────────────────────────────────────────

  Future<List<LessonModel>> getLessonsBySubject(String subjectId) async {
    try {
      final snapshot = await _db
          .collection(AppConstants.lessonsCollection)
          .where('subjectId', isEqualTo: subjectId)
          .orderBy('createdAt', descending: false)
          .get();
      return snapshot.docs
          .map((doc) =>
              LessonModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (_) {
      return []; // Offline fallback — callers use SampleLessons
    }
  }

  Future<LessonModel?> getLesson(String lessonId) async {
    try {
      final doc = await _db
          .collection(AppConstants.lessonsCollection)
          .doc(lessonId)
          .get();
      if (!doc.exists) return null;
      return LessonModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLesson(LessonModel lesson) async {
    try {
      await _db
          .collection(AppConstants.lessonsCollection)
          .doc(lesson.id)
          .set(lesson.toJson());
    } catch (_) {}
  }

  Future<List<LessonModel>> getRecommendedLessons(
    String uid,
    List<String> weakSubjects,
  ) async {
    try {
      final snapshot = await _db
          .collection(AppConstants.lessonsCollection)
          .where('subjectId', whereIn: weakSubjects.isEmpty
              ? ['math', 'science']
              : weakSubjects)
          .limit(5)
          .get();
      return snapshot.docs
          .map((doc) =>
              LessonModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Progress Operations ───────────────────────────────────────────────────

  Future<ProgressModel?> getProgress(String uid) async {
    try {
      final doc = await _db
          .collection(AppConstants.progressCollection)
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      return ProgressModel.fromJson(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProgress(ProgressModel progress) async {
    try {
      await _db
          .collection(AppConstants.progressCollection)
          .doc(progress.userId)
          .set(progress.toJson(), SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> markLessonComplete(
    String uid,
    String lessonId,
    String subjectId,
    int xpEarned,
  ) async {
    try {
      final docRef = _db
          .collection(AppConstants.progressCollection)
          .doc(uid);

      await _db.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        final data = snap.data() ?? {};
        final currentXp = (data['totalXp'] as num?)?.toInt() ?? 0;
        final newXp = currentXp + xpEarned;
        final newLevel = (newXp ~/ 500) + 1;
        final currentLessons =
            (data['totalLessonsCompleted'] as num?)?.toInt() ?? 0;

        final today = DateTime.now()
            .toIso8601String()
            .substring(0, 10);
        final dailyXp = Map<String, dynamic>.from(
            data['dailyXp'] as Map? ?? {});
        dailyXp[today] =
            ((dailyXp[today] as num?)?.toInt() ?? 0) + xpEarned;

        tx.set(
          docRef,
          {
            'userId': uid,
            'totalXp': newXp,
            'level': newLevel,
            'totalLessonsCompleted': currentLessons + 1,
            'lastActiveAt': DateTime.now().toIso8601String(),
            'dailyXp': dailyXp,
          },
          SetOptions(merge: true),
        );
      });
    } catch (_) {}
  }

  // ── Chat History ──────────────────────────────────────────────────────────

  Future<void> saveChatMessage(
    String uid,
    ChatMessageModel message,
  ) async {
    try {
      await _db
          .collection(AppConstants.chatHistoryCollection)
          .doc(uid)
          .collection('messages')
          .add(message.toJson());
    } catch (_) {}
  }

  Future<List<ChatMessageModel>> getChatHistory(
    String uid, {
    int limit = 50,
  }) async {
    if (!_isFirebaseReady) return [];
    try {
      final snapshot = await _db
          .collection(AppConstants.chatHistoryCollection)
          .doc(uid)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .limitToLast(limit)
          .get();

      return snapshot.docs
          .map((doc) => ChatMessageModel.fromJson(doc.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearChatHistory(String uid) async {
    if (!_isFirebaseReady) return;
    try {
      final snapshot = await _db
          .collection(AppConstants.chatHistoryCollection)
          .doc(uid)
          .collection('messages')
          .get();

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (_) {}
  }

  // ── Career Reports ────────────────────────────────────────────────────────

  Future<void> saveCareerReport(CareerModel career) async {
    if (!_isFirebaseReady) return;
    try {
      await _db
          .collection(AppConstants.careerReportsCollection)
          .doc(career.id)
          .set(career.toJson());
    } catch (_) {}
  }

  Future<CareerModel?> getLatestCareerReport(String uid) async {
    if (!_isFirebaseReady) return null;
    try {
      final snapshot = await _db
          .collection(AppConstants.careerReportsCollection)
          .where('userId', isEqualTo: uid)
          .orderBy('generatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return CareerModel.fromJson(snapshot.docs.first.data());
    } catch (_) {
      return null;
    }
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getNotifications(
    String uid, {
    int limit = 20,
  }) async {
    if (!_isFirebaseReady) return [];
    try {
      final snapshot = await _db
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> markNotificationRead(String notificationId) async {
    if (!_isFirebaseReady) return;
    try {
      await _db
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (_) {}
  }

  // ── Attendance (Teacher/Parent) ───────────────────────────────────────────

  Future<void> markAttendance({
    required String studentId,
    required String teacherId,
    required bool isPresent,
    required DateTime date,
  }) async {
    if (!_isFirebaseReady) return;
    try {
      final dateStr = date.toIso8601String().substring(0, 10);
      await _db
          .collection(AppConstants.attendanceCollection)
          .doc('${studentId}_$dateStr')
          .set({
        'studentId': studentId,
        'teacherId': teacherId,
        'isPresent': isPresent,
        'date': dateStr,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> getStudentAttendance(
    String studentId, {
    int lastDays = 30,
  }) async {
    if (!_isFirebaseReady) return [];
    try {
      final from = DateTime.now()
          .subtract(Duration(days: lastDays))
          .toIso8601String()
          .substring(0, 10);

      final snapshot = await _db
          .collection(AppConstants.attendanceCollection)
          .where('studentId', isEqualTo: studentId)
          .where('date', isGreaterThanOrEqualTo: from)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Leaderboard ───────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getLeaderboard({
    int limit = 20,
  }) async {
    if (!_isFirebaseReady) return [];
    try {
      final snapshot = await _db
          .collection(AppConstants.usersCollection)
          .where('role', isEqualTo: 'student')
          .orderBy('totalXp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (_) {
      return [];
    }
  }
}
