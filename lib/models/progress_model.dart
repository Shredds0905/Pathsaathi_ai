/// PathSaathi AI — Progress & Achievement Models

class ProgressModel {
  final String userId;
  final Map<String, SubjectProgress> subjects;
  final int totalXp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final int totalLessonsCompleted;
  final int totalQuizzesCompleted;
  final int totalTimeSpentMinutes;
  final List<String> earnedBadgeIds;
  final DateTime lastActiveAt;
  final Map<String, int> dailyXp; // date string → xp earned

  const ProgressModel({
    required this.userId,
    this.subjects = const {},
    this.totalXp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalLessonsCompleted = 0,
    this.totalQuizzesCompleted = 0,
    this.totalTimeSpentMinutes = 0,
    this.earnedBadgeIds = const [],
    required this.lastActiveAt,
    this.dailyXp = const {},
  });

  double get levelProgress => (totalXp % 500) / 500;
  int get xpForNextLevel => (level) * 500;
  int get xpInCurrentLevel => totalXp % 500;

  factory ProgressModel.initial(String userId) {
    return ProgressModel(
      userId: userId,
      lastActiveAt: DateTime.now(),
    );
  }

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      userId: json['userId'] as String? ?? '',
      subjects: (json['subjects'] as Map<String, dynamic>? ?? {}).map(
        (k, v) => MapEntry(
          k,
          SubjectProgress.fromJson(v as Map<String, dynamic>),
        ),
      ),
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      totalLessonsCompleted:
          (json['totalLessonsCompleted'] as num?)?.toInt() ?? 0,
      totalQuizzesCompleted:
          (json['totalQuizzesCompleted'] as num?)?.toInt() ?? 0,
      totalTimeSpentMinutes:
          (json['totalTimeSpentMinutes'] as num?)?.toInt() ?? 0,
      earnedBadgeIds:
          List<String>.from(json['earnedBadgeIds'] as List? ?? []),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : DateTime.now(),
      dailyXp: Map<String, int>.from(
        (json['dailyXp'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'subjects':
            subjects.map((k, v) => MapEntry(k, v.toJson())),
        'totalXp': totalXp,
        'level': level,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'totalLessonsCompleted': totalLessonsCompleted,
        'totalQuizzesCompleted': totalQuizzesCompleted,
        'totalTimeSpentMinutes': totalTimeSpentMinutes,
        'earnedBadgeIds': earnedBadgeIds,
        'lastActiveAt': lastActiveAt.toIso8601String(),
        'dailyXp': dailyXp,
      };
}

class SubjectProgress {
  final String subjectId;
  final int lessonsCompleted;
  final int totalLessons;
  final double averageScore;
  final int xpEarned;

  const SubjectProgress({
    required this.subjectId,
    this.lessonsCompleted = 0,
    this.totalLessons = 10,
    this.averageScore = 0,
    this.xpEarned = 0,
  });

  double get completionPercent =>
      totalLessons > 0 ? lessonsCompleted / totalLessons : 0;

  factory SubjectProgress.fromJson(Map<String, dynamic> json) {
    return SubjectProgress(
      subjectId: json['subjectId'] as String? ?? '',
      lessonsCompleted: (json['lessonsCompleted'] as num?)?.toInt() ?? 0,
      totalLessons: (json['totalLessons'] as num?)?.toInt() ?? 10,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'subjectId': subjectId,
        'lessonsCompleted': lessonsCompleted,
        'totalLessons': totalLessons,
        'averageScore': averageScore,
        'xpEarned': xpEarned,
      };
}

/// Achievement / Badge Model
class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int xpReward;
  final AchievementType type;
  final bool isEarned;
  final DateTime? earnedAt;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.xpReward = 50,
    this.type = AchievementType.milestone,
    this.isEarned = false,
    this.earnedAt,
  });

  AchievementModel copyWith({bool? isEarned, DateTime? earnedAt}) {
    return AchievementModel(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      xpReward: xpReward,
      type: type,
      isEarned: isEarned ?? this.isEarned,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }
}

enum AchievementType { milestone, streak, subject, social, special }

/// Static achievement definitions
class Achievements {
  static List<AchievementModel> get all => [
        const AchievementModel(
          id: 'first_lesson',
          title: 'First Step',
          description: 'Complete your first lesson',
          emoji: '🎯',
          xpReward: 50,
          type: AchievementType.milestone,
        ),
        const AchievementModel(
          id: 'streak_3',
          title: '3-Day Streak',
          description: 'Learn for 3 days in a row',
          emoji: '🔥',
          xpReward: 75,
          type: AchievementType.streak,
        ),
        const AchievementModel(
          id: 'streak_7',
          title: 'Week Warrior',
          description: 'Maintain a 7-day streak',
          emoji: '⚡',
          xpReward: 150,
          type: AchievementType.streak,
        ),
        const AchievementModel(
          id: 'streak_30',
          title: 'Monthly Champion',
          description: 'Keep your streak for 30 days',
          emoji: '👑',
          xpReward: 500,
          type: AchievementType.streak,
        ),
        const AchievementModel(
          id: 'quiz_master',
          title: 'Quiz Master',
          description: 'Score 100% in any quiz',
          emoji: '🏆',
          xpReward: 200,
          type: AchievementType.milestone,
        ),
        const AchievementModel(
          id: 'explorer',
          title: 'Explorer',
          description: 'Study 5 different subjects',
          emoji: '🔭',
          xpReward: 100,
          type: AchievementType.subject,
        ),
        const AchievementModel(
          id: 'speed_learner',
          title: 'Speed Learner',
          description: 'Complete 5 lessons in one day',
          emoji: '🚀',
          xpReward: 150,
          type: AchievementType.milestone,
        ),
        const AchievementModel(
          id: 'ai_friend',
          title: 'AI Friend',
          description: 'Have 10 conversations with AI Teacher',
          emoji: '🤖',
          xpReward: 75,
          type: AchievementType.social,
        ),
        const AchievementModel(
          id: 'level_5',
          title: 'Level 5 Scholar',
          description: 'Reach Level 5',
          emoji: '⭐',
          xpReward: 250,
          type: AchievementType.milestone,
        ),
        const AchievementModel(
          id: 'offline_learner',
          title: 'Offline Champion',
          description: 'Complete a lesson offline',
          emoji: '📱',
          xpReward: 100,
          type: AchievementType.special,
        ),
      ];
}
