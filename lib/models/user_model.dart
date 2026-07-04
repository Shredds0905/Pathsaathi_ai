/// PathSaathi AI — User Model

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String role; // student | teacher | parent | guest
  final String language;
  final String? grade;
  final String? school;
  final int age;
  final List<String> interests;
  final List<String> weakSubjects;
  final String learningGoal;
  final String learningSpeed; // slow | medium | fast
  final bool isOnboardingDone;
  final int totalXp;
  final int level;
  final int currentStreak;
  final int totalLessonsCompleted;
  final int totalQuizCompleted;
  final int longestStreak;
  final List<String> badges;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final String? parentId;   // for student accounts
  final String? studentId;  // for parent accounts

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.role = 'student',
    this.language = 'en',
    this.grade,
    this.school,
    this.age = 0,
    this.interests = const [],
    this.weakSubjects = const [],
    this.learningGoal = '',
    this.learningSpeed = 'medium',
    this.isOnboardingDone = false,
    this.totalXp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.totalLessonsCompleted = 0,
    this.totalQuizCompleted = 0,
    this.longestStreak = 0,
    this.badges = const [],
    required this.createdAt,
    this.lastActiveAt,
    this.parentId,
    this.studentId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      role: json['role'] as String? ?? 'student',
      language: json['language'] as String? ?? 'en',
      grade: json['grade'] as String?,
      school: json['school'] as String?,
      age: (json['age'] as num?)?.toInt() ?? 0,
      interests: List<String>.from(json['interests'] as List? ?? []),
      weakSubjects: List<String>.from(json['weakSubjects'] as List? ?? []),
      learningGoal: json['learningGoal'] as String? ?? '',
      learningSpeed: json['learningSpeed'] as String? ?? 'medium',
      isOnboardingDone: json['isOnboardingDone'] as bool? ?? false,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      totalLessonsCompleted:
          (json['totalLessonsCompleted'] as num?)?.toInt() ?? 0,
      totalQuizCompleted: (json['totalQuizCompleted'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      badges: List<String>.from(json['badges'] as List? ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
      parentId: json['parentId'] as String?,
      studentId: json['studentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'language': language,
      'grade': grade,
      'school': school,
      'age': age,
      'interests': interests,
      'weakSubjects': weakSubjects,
      'learningGoal': learningGoal,
      'learningSpeed': learningSpeed,
      'isOnboardingDone': isOnboardingDone,
      'totalXp': totalXp,
      'level': level,
      'currentStreak': currentStreak,
      'totalLessonsCompleted': totalLessonsCompleted,
      'totalQuizCompleted': totalQuizCompleted,
      'longestStreak': longestStreak,
      'badges': badges,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'parentId': parentId,
      'studentId': studentId,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? role,
    String? language,
    String? grade,
    String? school,
    int? age,
    List<String>? interests,
    List<String>? weakSubjects,
    String? learningGoal,
    String? learningSpeed,
    bool? isOnboardingDone,
    int? totalXp,
    int? level,
    int? currentStreak,
    int? totalLessonsCompleted,
    int? totalQuizCompleted,
    int? longestStreak,
    List<String>? badges,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    String? parentId,
    String? studentId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      language: language ?? this.language,
      grade: grade ?? this.grade,
      school: school ?? this.school,
      age: age ?? this.age,
      interests: interests ?? this.interests,
      weakSubjects: weakSubjects ?? this.weakSubjects,
      learningGoal: learningGoal ?? this.learningGoal,
      learningSpeed: learningSpeed ?? this.learningSpeed,
      isOnboardingDone: isOnboardingDone ?? this.isOnboardingDone,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      totalLessonsCompleted:
          totalLessonsCompleted ?? this.totalLessonsCompleted,
      totalQuizCompleted: totalQuizCompleted ?? this.totalQuizCompleted,
      longestStreak: longestStreak ?? this.longestStreak,
      badges: badges ?? this.badges,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      parentId: parentId ?? this.parentId,
      studentId: studentId ?? this.studentId,
    );
  }

  /// Returns the next level XP threshold
  int get xpForNextLevel => level * 500;

  /// Returns XP progress within current level
  int get xpInCurrentLevel => totalXp % 500;

  /// Returns progress as a fraction 0.0–1.0
  double get levelProgress => xpInCurrentLevel / 500;

  /// Alias for totalQuizCompleted
  int get totalQuizzesCompleted => totalQuizCompleted;

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, role: $role)';
}
