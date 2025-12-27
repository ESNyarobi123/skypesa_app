class Plan {
  final int id;
  final String name;
  final String? slug;
  final String description;
  final double price;
  final int? durationDays;
  final int dailyTaskLimit;
  final double rewardPerTask;
  final double minWithdrawal;
  final double withdrawalFeePercent;
  final List<String> features;
  final bool isPopular;

  Plan({
    required this.id,
    required this.name,
    this.slug,
    required this.description,
    required this.price,
    this.durationDays,
    required this.dailyTaskLimit,
    required this.rewardPerTask,
    required this.minWithdrawal,
    required this.withdrawalFeePercent,
    required this.features,
    this.isPopular = false,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    // Parse features - could be null, string, or list
    List<String> features = [];
    if (json['features'] != null) {
      if (json['features'] is List) {
        features = List<String>.from(json['features']);
      } else if (json['features'] is String) {
        features = [json['features']];
      }
    }

    // If no features provided, generate some based on the plan
    if (features.isEmpty) {
      final dailyLimit = json['daily_task_limit'] ?? 0;
      final reward = _parseDouble(json['reward_per_task']);
      final fee = _parseDouble(json['withdrawal_fee_percent']);

      features = [
        '$dailyLimit tasks per day',
        'TZS ${reward.toStringAsFixed(0)} per task',
        '${fee.toStringAsFixed(0)}% withdrawal fee',
      ];
    }

    return Plan(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      description: json['description']?.toString() ?? '',
      price: _parseDouble(json['price']),
      durationDays: json['duration_days'],
      dailyTaskLimit: json['daily_task_limit'] ?? 0,
      rewardPerTask: _parseDouble(json['reward_per_task']),
      minWithdrawal: _parseDouble(json['min_withdrawal']),
      withdrawalFeePercent: _parseDouble(json['withdrawal_fee_percent']),
      features: features,
      isPopular: json['is_popular'] == true,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Display name with proper capitalization
  String get displayName {
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  // Check if this is a premium plan
  bool get isPremium {
    final lowerName = name.toLowerCase();
    return lowerName == 'vip' || lowerName == 'gold' || lowerName == 'silver';
  }
}
