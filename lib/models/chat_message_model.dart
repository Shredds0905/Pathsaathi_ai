/// PathSaathi AI — Chat Message Model

enum MessageRole { user, assistant, system }

class ChatMessageModel {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final String? imageUrl;
  final bool isLoading;
  final String language;

  const ChatMessageModel({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.imageUrl,
    this.isLoading = false,
    this.language = 'en',
  });

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;

  factory ChatMessageModel.user({
    required String content,
    String? imageUrl,
    String language = 'en',
  }) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
      language: language,
    );
  }

  factory ChatMessageModel.assistant({
    required String content,
    String language = 'en',
    bool isLoading = false,
  }) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      language: language,
      isLoading: isLoading,
    );
  }

  factory ChatMessageModel.loading() {
    return ChatMessageModel(
      id: 'loading',
      content: '',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      role: MessageRole.values.firstWhere(
        (r) => r.name == (json['role'] as String? ?? 'user'),
        orElse: () => MessageRole.user,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      imageUrl: json['imageUrl'] as String?,
      language: json['language'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'language': language,
    };
  }

  /// Convert to Gemini API format
  Map<String, dynamic> toGeminiPart() {
    return {
      'role': role == MessageRole.user ? 'user' : 'model',
      'parts': [
        if (imageUrl != null)
          {'inlineData': ''},
        {'text': content},
      ],
    };
  }
}
