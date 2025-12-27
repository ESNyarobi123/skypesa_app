class Task {
  final int id;
  final String title;
  final String description;
  final String type; // 'video_ad', 'view_ad'
  final String? provider;
  final int durationSeconds;
  final double reward;
  final bool isFeatured;
  final String? thumbnail;
  final String? icon;
  final int dailyLimit;
  final int completionsToday;
  final int remaining;
  final bool canComplete;
  final bool isUnlimited;
  final String? url;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.provider,
    required this.durationSeconds,
    required this.reward,
    this.isFeatured = false,
    this.thumbnail,
    this.icon,
    this.dailyLimit = 0,
    this.completionsToday = 0,
    this.remaining = 0,
    this.canComplete = true,
    this.isUnlimited = false,
    this.url,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'view_ad',
      provider: json['provider']?.toString(),
      durationSeconds: json['duration_seconds'] ?? 30,
      reward: _parseDouble(json['reward']),
      isFeatured: json['is_featured'] == true,
      thumbnail: json['thumbnail']?.toString(),
      icon: json['icon']?.toString(),
      dailyLimit: json['daily_limit'] ?? 0,
      completionsToday: json['completions_today'] ?? 0,
      remaining: json['remaining'] ?? 0,
      canComplete: json['can_complete'] ?? true,
      isUnlimited: json['is_unlimited'] == true,
      url: json['url']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
