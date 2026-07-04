/// PathSaathi AI — Career Guidance Model

class CareerModel {
  final String id;
  final String userId;
  final CareerInput input;
  final List<CareerSuggestion> suggestions;
  final List<ScholarshipModel> scholarships;
  final List<CourseModel> recommendedCourses;
  final List<GovernmentScheme> governmentSchemes;
  final String roadmapSummary;
  final DateTime generatedAt;

  const CareerModel({
    required this.id,
    required this.userId,
    required this.input,
    required this.suggestions,
    this.scholarships = const [],
    this.recommendedCourses = const [],
    this.governmentSchemes = const [],
    this.roadmapSummary = '',
    required this.generatedAt,
  });

  factory CareerModel.fromJson(Map<String, dynamic> json) {
    return CareerModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      input: CareerInput.fromJson(
          json['input'] as Map<String, dynamic>? ?? {}),
      suggestions: (json['suggestions'] as List? ?? [])
          .map((s) =>
              CareerSuggestion.fromJson(s as Map<String, dynamic>))
          .toList(),
      scholarships: (json['scholarships'] as List? ?? [])
          .map((s) =>
              ScholarshipModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      recommendedCourses: (json['recommendedCourses'] as List? ?? [])
          .map((c) => CourseModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      governmentSchemes: (json['governmentSchemes'] as List? ?? [])
          .map((g) =>
              GovernmentScheme.fromJson(g as Map<String, dynamic>))
          .toList(),
      roadmapSummary: json['roadmapSummary'] as String? ?? '',
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'input': input.toJson(),
        'suggestions': suggestions.map((s) => s.toJson()).toList(),
        'scholarships': scholarships.map((s) => s.toJson()).toList(),
        'recommendedCourses':
            recommendedCourses.map((c) => c.toJson()).toList(),
        'governmentSchemes':
            governmentSchemes.map((g) => g.toJson()).toList(),
        'roadmapSummary': roadmapSummary,
        'generatedAt': generatedAt.toIso8601String(),
      };
}

class CareerInput {
  final List<String> interests;
  final String education; // 10th | 12th | graduate | dropout
  final String marksRange; // <40 | 40-60 | 60-80 | 80-100
  final List<String> skills;
  final String financialBackground; // low | middle | high
  final String preferredLanguage;
  final String location; // state/city
  final String gender;
  final bool needsScholarship;

  const CareerInput({
    required this.interests,
    required this.education,
    required this.marksRange,
    this.skills = const [],
    this.financialBackground = 'low',
    this.preferredLanguage = 'en',
    this.location = '',
    this.gender = '',
    this.needsScholarship = false,
  });

  factory CareerInput.fromJson(Map<String, dynamic> json) {
    return CareerInput(
      interests: List<String>.from(json['interests'] as List? ?? []),
      education: json['education'] as String? ?? '',
      marksRange: json['marksRange'] as String? ?? '',
      skills: List<String>.from(json['skills'] as List? ?? []),
      financialBackground:
          json['financialBackground'] as String? ?? 'low',
      preferredLanguage:
          json['preferredLanguage'] as String? ?? 'en',
      location: json['location'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      needsScholarship: json['needsScholarship'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'interests': interests,
        'education': education,
        'marksRange': marksRange,
        'skills': skills,
        'financialBackground': financialBackground,
        'preferredLanguage': preferredLanguage,
        'location': location,
        'gender': gender,
        'needsScholarship': needsScholarship,
      };
}

class CareerSuggestion {
  final String title;
  final String field;
  final String description;
  final String requiredEducation;
  final List<String> requiredSkills;
  final String salaryRange;
  final double matchScore; // 0.0–1.0
  final String emoji;
  final List<String> steps;

  const CareerSuggestion({
    required this.title,
    required this.field,
    required this.description,
    required this.requiredEducation,
    required this.requiredSkills,
    required this.salaryRange,
    required this.matchScore,
    required this.emoji,
    this.steps = const [],
  });

  factory CareerSuggestion.fromJson(Map<String, dynamic> json) {
    return CareerSuggestion(
      title: json['title'] as String? ?? '',
      field: json['field'] as String? ?? '',
      description: json['description'] as String? ?? '',
      requiredEducation: json['requiredEducation'] as String? ?? '',
      requiredSkills:
          List<String>.from(json['requiredSkills'] as List? ?? []),
      salaryRange: json['salaryRange'] as String? ?? '',
      matchScore: (json['matchScore'] as num?)?.toDouble() ?? 0,
      emoji: json['emoji'] as String? ?? '💼',
      steps: List<String>.from(json['steps'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'field': field,
        'description': description,
        'requiredEducation': requiredEducation,
        'requiredSkills': requiredSkills,
        'salaryRange': salaryRange,
        'matchScore': matchScore,
        'emoji': emoji,
        'steps': steps,
      };
}

class ScholarshipModel {
  final String name;
  final String provider;
  final String amount;
  final String eligibility;
  final String deadline;
  final String applicationUrl;
  final bool forGirls;
  final bool forMinorities;

  const ScholarshipModel({
    required this.name,
    required this.provider,
    required this.amount,
    required this.eligibility,
    required this.deadline,
    required this.applicationUrl,
    this.forGirls = false,
    this.forMinorities = false,
  });

  factory ScholarshipModel.fromJson(Map<String, dynamic> json) {
    return ScholarshipModel(
      name: json['name'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
      eligibility: json['eligibility'] as String? ?? '',
      deadline: json['deadline'] as String? ?? '',
      applicationUrl: json['applicationUrl'] as String? ?? '',
      forGirls: json['forGirls'] as bool? ?? false,
      forMinorities: json['forMinorities'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'provider': provider,
        'amount': amount,
        'eligibility': eligibility,
        'deadline': deadline,
        'applicationUrl': applicationUrl,
        'forGirls': forGirls,
        'forMinorities': forMinorities,
      };
}

class CourseModel {
  final String title;
  final String provider;
  final String duration;
  final bool isFree;
  final String url;
  final String level;
  final String emoji;

  const CourseModel({
    required this.title,
    required this.provider,
    required this.duration,
    required this.isFree,
    required this.url,
    required this.level,
    required this.emoji,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      title: json['title'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      isFree: json['isFree'] as bool? ?? true,
      url: json['url'] as String? ?? '',
      level: json['level'] as String? ?? 'beginner',
      emoji: json['emoji'] as String? ?? '📖',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'provider': provider,
        'duration': duration,
        'isFree': isFree,
        'url': url,
        'level': level,
        'emoji': emoji,
      };
}

class GovernmentScheme {
  final String name;
  final String description;
  final String eligibility;
  final String benefit;
  final String applicationProcess;
  final String ministry;

  const GovernmentScheme({
    required this.name,
    required this.description,
    required this.eligibility,
    required this.benefit,
    required this.applicationProcess,
    required this.ministry,
  });

  factory GovernmentScheme.fromJson(Map<String, dynamic> json) {
    return GovernmentScheme(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      eligibility: json['eligibility'] as String? ?? '',
      benefit: json['benefit'] as String? ?? '',
      applicationProcess: json['applicationProcess'] as String? ?? '',
      ministry: json['ministry'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'eligibility': eligibility,
        'benefit': benefit,
        'applicationProcess': applicationProcess,
        'ministry': ministry,
      };
}
