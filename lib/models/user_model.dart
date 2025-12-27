class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? referralCode;
  final bool isVerified;
  final UserSubscription? subscription;
  final UserWallet? wallet;
  final String? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.referralCode,
    this.isVerified = false,
    this.subscription,
    this.wallet,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Safely parse subscription - API returns {"plan": "vip", "expires_at": "..."}
    UserSubscription? subscription;
    final subData = json['subscription'];
    if (subData != null) {
      if (subData is Map<String, dynamic>) {
        subscription = UserSubscription.fromJson(subData);
      } else if (subData is String) {
        // Handle case where subscription is just the plan name string
        subscription = UserSubscription(planName: subData);
      }
    }

    // Safely parse wallet - API returns {"balance": "2098.00"}
    UserWallet? wallet;
    final walletData = json['wallet'];
    if (walletData != null && walletData is Map<String, dynamic>) {
      wallet = UserWallet.fromJson(walletData);
    }

    return User(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
      referralCode: json['referral_code']?.toString(),
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      subscription: subscription,
      wallet: wallet,
      createdAt: json['created_at']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'referral_code': referralCode,
      'is_verified': isVerified,
    };
  }
}

class UserSubscription {
  final String? planName;
  final String? expiresAt;

  UserSubscription({this.planName, this.expiresAt});

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      planName: json['plan']?.toString(),
      expiresAt: json['expires_at']?.toString(),
    );
  }

  // Helper to get display name with capitalization
  String get displayName {
    if (planName == null || planName!.isEmpty) return 'Free';
    return planName![0].toUpperCase() + planName!.substring(1).toLowerCase();
  }
}

class UserWallet {
  final double balance;
  final double? totalEarned;
  final double? totalWithdrawn;
  final int? pendingWithdrawals;

  UserWallet({
    required this.balance,
    this.totalEarned,
    this.totalWithdrawn,
    this.pendingWithdrawals,
  });

  factory UserWallet.fromJson(Map<String, dynamic> json) {
    return UserWallet(
      balance: _parseDouble(json['balance']),
      totalEarned: json['total_earned'] != null
          ? _parseDouble(json['total_earned'])
          : null,
      totalWithdrawn: json['total_withdrawn'] != null
          ? _parseDouble(json['total_withdrawn'])
          : null,
      pendingWithdrawals: json['pending_withdrawals'] is int
          ? json['pending_withdrawals']
          : null,
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

// Dashboard data model
class DashboardData {
  final double walletBalance;
  final int tasksToday;
  final int tasksLimit;
  final int tasksRemaining;
  final double rewardPerTask;
  final EarningsData earnings;
  final String subscription;
  final int referralCount;

  DashboardData({
    required this.walletBalance,
    required this.tasksToday,
    required this.tasksLimit,
    required this.tasksRemaining,
    required this.rewardPerTask,
    required this.earnings,
    required this.subscription,
    required this.referralCount,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      walletBalance: _parseDouble(json['wallet_balance']),
      tasksToday: json['tasks_today'] ?? 0,
      tasksLimit: json['tasks_limit'] ?? 0,
      tasksRemaining: json['tasks_remaining'] ?? 0,
      rewardPerTask: _parseDouble(json['reward_per_task']),
      earnings: EarningsData.fromJson(json['earnings'] ?? {}),
      subscription: json['subscription']?.toString() ?? 'free',
      referralCount: json['referral_count'] ?? 0,
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

class EarningsData {
  final double today;
  final double thisWeek;
  final double thisMonth;

  EarningsData({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
  });

  factory EarningsData.fromJson(Map<String, dynamic> json) {
    return EarningsData(
      today: _parseDouble(json['today']),
      thisWeek: _parseDouble(json['this_week']),
      thisMonth: _parseDouble(json['this_month']),
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

// Leaderboard models
class LeaderboardEntry {
  final int rank;
  final LeaderboardUser user;
  final double totalEarnings;
  final int tasksCompleted;

  LeaderboardEntry({
    required this.rank,
    required this.user,
    required this.totalEarnings,
    required this.tasksCompleted,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      user: LeaderboardUser.fromJson(json['user'] ?? {}),
      totalEarnings: _parseDouble(json['total_earnings']),
      tasksCompleted: json['tasks_completed'] ?? 0,
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

class LeaderboardUser {
  final int id;
  final String name;
  final String? avatar;

  LeaderboardUser({required this.id, required this.name, this.avatar});

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? 'User',
      avatar: json['avatar']?.toString(),
    );
  }
}

class MyRank {
  final int rank;
  final double totalEarnings;
  final int tasksCompleted;

  MyRank({
    required this.rank,
    required this.totalEarnings,
    required this.tasksCompleted,
  });

  factory MyRank.fromJson(Map<String, dynamic> json) {
    return MyRank(
      rank: json['rank'] ?? 0,
      totalEarnings: _parseDouble(json['total_earnings']),
      tasksCompleted: json['tasks_completed'] ?? 0,
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

// Referral models
class ReferralData {
  final String referralCode;
  final String referralLink;
  final int totalReferrals;
  final int activeReferrals;
  final double totalEarnings;
  final String shareMessage;

  ReferralData({
    required this.referralCode,
    required this.referralLink,
    required this.totalReferrals,
    required this.activeReferrals,
    required this.totalEarnings,
    required this.shareMessage,
  });

  factory ReferralData.fromJson(Map<String, dynamic> json) {
    return ReferralData(
      referralCode: json['referral_code']?.toString() ?? '',
      referralLink: json['referral_link']?.toString() ?? '',
      totalReferrals: json['total_referrals'] ?? 0,
      activeReferrals: json['active_referrals'] ?? 0,
      totalEarnings: _parseDouble(json['total_earnings']),
      shareMessage: json['share_message']?.toString() ?? '',
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
