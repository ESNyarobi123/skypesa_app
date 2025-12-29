import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';

class UserService {
  final Dio _dio = Dio();

  UserService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
      ),
    );
  }

  Future<UserProfile?> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      if (response.data['success'] == true && response.data['data'] != null) {
        return UserProfile.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      developer.log('Error fetching profile: $e');
      return null;
    }
  }

  Future<ApiResult> updateProfile({String? name, String? phone}) async {
    try {
      final response = await _dio.put(
        ApiConstants.profile,
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
        },
      );
      return ApiResult(
        success: response.data['success'] == true,
        message: response.data['message'] ?? 'Updated',
      );
    } on DioException catch (e) {
      return ApiResult(
        success: false,
        message: _handleError(e),
        errors: _extractErrors(e),
      );
    }
  }

  Future<ApiResult> uploadAvatar(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'avatar.jpg',
        ),
      });
      final response = await _dio.post(
        ApiConstants.updateAvatar,
        data: formData,
      );
      return ApiResult(
        success: response.data['success'] == true,
        message: response.data['message'] ?? 'Picha imebadilishwa',
        data: response.data['data'],
      );
    } on DioException catch (e) {
      return ApiResult(success: false, message: _handleError(e));
    }
  }

  Future<ApiResult> deleteAvatar() async {
    try {
      final response = await _dio.delete(ApiConstants.updateAvatar);
      return ApiResult(
        success: response.data['success'] == true,
        message: response.data['message'] ?? 'Picha imeondolewa',
      );
    } on DioException catch (e) {
      return ApiResult(success: false, message: _handleError(e));
    }
  }

  Future<ApiResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );
      return ApiResult(
        success: response.data['success'] == true,
        message: response.data['message'] ?? 'Password imebadilishwa',
      );
    } on DioException catch (e) {
      return ApiResult(
        success: false,
        message: _handleError(e),
        errors: _extractErrors(e),
      );
    }
  }

  Future<UserActivity?> getActivity() async {
    try {
      final response = await _dio.get('/user/activity');
      if (response.data['success'] == true)
        return UserActivity.fromJson(response.data['data']);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<ApiResult> deleteAccount({
    required String password,
    required String confirmation,
  }) async {
    try {
      final response = await _dio.delete(
        '/user/account',
        data: {'password': password, 'confirmation': confirmation},
      );
      return ApiResult(
        success: response.data['success'] == true,
        message: response.data['message'] ?? 'Akaunti imefutwa',
      );
    } on DioException catch (e) {
      return ApiResult(success: false, message: _handleError(e));
    }
  }

  String _handleError(DioException e) {
    if (e.response?.data is Map && e.response?.data['message'] != null)
      return e.response?.data['message'];
    return 'Connection error';
  }

  Map<String, List<String>>? _extractErrors(DioException e) {
    if (e.response?.data is Map && e.response?.data['errors'] != null) {
      return (e.response?.data['errors'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as List).map((e) => e.toString()).toList()),
      );
    }
    return null;
  }
}

class ApiResult {
  final bool success;
  final String message;
  final dynamic data;
  final Map<String, List<String>>? errors;
  ApiResult({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });
}

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String referralCode;
  final bool isVerified;
  final UserWallet wallet;
  final UserSubscription? subscription;
  final UserStats stats;
  final String createdAt;
  final String? lastLoginAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.referralCode,
    required this.isVerified,
    required this.wallet,
    this.subscription,
    required this.stats,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] ?? 0,
    name: json['name']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    phone: json['phone']?.toString(),
    avatar: json['avatar']?.toString(),
    referralCode: json['referral_code']?.toString() ?? '',
    isVerified: json['is_verified'] == true,
    wallet: UserWallet.fromJson(json['wallet'] ?? {}),
    subscription: json['subscription'] != null
        ? UserSubscription.fromJson(json['subscription'])
        : null,
    stats: UserStats.fromJson(json['stats'] ?? {}),
    createdAt: json['created_at']?.toString() ?? '',
    lastLoginAt: json['last_login_at']?.toString(),
  );
}

class UserWallet {
  final double balance;
  final String balanceFormatted;
  final double totalEarned;
  final double totalWithdrawn;
  final double pendingWithdrawal;

  UserWallet({
    required this.balance,
    required this.balanceFormatted,
    required this.totalEarned,
    required this.totalWithdrawn,
    required this.pendingWithdrawal,
  });

  factory UserWallet.fromJson(Map<String, dynamic> json) => UserWallet(
    balance: _p(json['balance']),
    balanceFormatted: json['balance_formatted']?.toString() ?? 'TZS 0',
    totalEarned: _p(json['total_earned']),
    totalWithdrawn: _p(json['total_withdrawn']),
    pendingWithdrawal: _p(json['pending_withdrawal']),
  );
  static double _p(dynamic v) => v is double
      ? v
      : v is int
      ? v.toDouble()
      : double.tryParse(v?.toString() ?? '') ?? 0.0;
}

class UserSubscription {
  final int id;
  final SubscriptionPlan plan;
  final String status;
  final String? startedAt;
  final String? expiresAt;
  final int daysRemaining;

  UserSubscription({
    required this.id,
    required this.plan,
    required this.status,
    this.startedAt,
    this.expiresAt,
    required this.daysRemaining,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) =>
      UserSubscription(
        id: json['id'] ?? 0,
        plan: SubscriptionPlan.fromJson(json['plan'] ?? {}),
        status: json['status']?.toString() ?? 'active',
        startedAt: json['started_at']?.toString(),
        expiresAt: json['expires_at']?.toString(),
        daysRemaining: json['days_remaining'] ?? 0,
      );
}

class SubscriptionPlan {
  final int id;
  final String name;
  final String displayName;
  final String slug;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.displayName,
    required this.slug,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      SubscriptionPlan(
        id: json['id'] ?? 0,
        name: json['name']?.toString() ?? '',
        displayName:
            json['display_name']?.toString() ??
            json['name']?.toString() ??
            'Free',
        slug: json['slug']?.toString() ?? 'free',
      );
}

class UserStats {
  final int tasksCompletedToday;
  final int dailyTaskLimit;
  final int remainingTasksToday;
  final double rewardPerTask;
  final int totalTasksCompleted;
  final int referralsCount;

  UserStats({
    required this.tasksCompletedToday,
    required this.dailyTaskLimit,
    required this.remainingTasksToday,
    required this.rewardPerTask,
    required this.totalTasksCompleted,
    required this.referralsCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    tasksCompletedToday: json['tasks_completed_today'] ?? 0,
    dailyTaskLimit: json['daily_task_limit'] ?? 5,
    remainingTasksToday: json['remaining_tasks_today'] ?? 5,
    rewardPerTask: _p(json['reward_per_task']),
    totalTasksCompleted: json['total_tasks_completed'] ?? 0,
    referralsCount: json['referrals_count'] ?? 0,
  );
  static double _p(dynamic v) => v is double
      ? v
      : v is int
      ? v.toDouble()
      : double.tryParse(v?.toString() ?? '') ?? 0.0;
}

class UserActivity {
  final List<RecentTask> recentTasks;
  final List<RecentTransaction> recentTransactions;

  UserActivity({required this.recentTasks, required this.recentTransactions});

  factory UserActivity.fromJson(Map<String, dynamic> json) => UserActivity(
    recentTasks: (json['recent_tasks'] as List? ?? [])
        .map((t) => RecentTask.fromJson(t))
        .toList(),
    recentTransactions: (json['recent_transactions'] as List? ?? [])
        .map((t) => RecentTransaction.fromJson(t))
        .toList(),
  );
}

class RecentTask {
  final int id;
  final String task;
  final String taskType;
  final double reward;
  final String rewardFormatted;
  final String completedAt;
  final String completedAtHuman;

  RecentTask({
    required this.id,
    required this.task,
    required this.taskType,
    required this.reward,
    required this.rewardFormatted,
    required this.completedAt,
    required this.completedAtHuman,
  });

  factory RecentTask.fromJson(Map<String, dynamic> json) => RecentTask(
    id: json['id'] ?? 0,
    task: json['task']?.toString() ?? '',
    taskType: json['task_type']?.toString() ?? '',
    reward: (json['reward'] is num) ? (json['reward'] as num).toDouble() : 0.0,
    rewardFormatted: json['reward_formatted']?.toString() ?? '',
    completedAt: json['completed_at']?.toString() ?? '',
    completedAtHuman: json['completed_at_human']?.toString() ?? '',
  );
}

class RecentTransaction {
  final int id;
  final String type;
  final double amount;
  final String amountFormatted;
  final String description;
  final String createdAt;
  final String createdAtHuman;

  RecentTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.amountFormatted,
    required this.description,
    required this.createdAt,
    required this.createdAtHuman,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) =>
      RecentTransaction(
        id: json['id'] ?? 0,
        type: json['type']?.toString() ?? '',
        amount: (json['amount'] is num)
            ? (json['amount'] as num).toDouble()
            : 0.0,
        amountFormatted: json['amount_formatted']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        createdAt: json['created_at']?.toString() ?? '',
        createdAtHuman: json['created_at_human']?.toString() ?? '',
      );
}
