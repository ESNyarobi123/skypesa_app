import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';

class PlanService {
  final Dio _dio = Dio();

  PlanService() {
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
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          developer.log('Plan API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  /// Get all available plans
  Future<List<Plan>> getPlans() async {
    try {
      final response = await _dio.get(ApiConstants.plans);
      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Plan.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      developer.log('Error fetching plans: $e');
      return [];
    }
  }

  /// Get current subscription
  Future<CurrentSubscription?> getCurrentSubscription() async {
    try {
      final response = await _dio.get(ApiConstants.currentSubscription);
      if (response.data['success'] == true) {
        return CurrentSubscription.fromJson(response.data);
      }
      return null;
    } catch (e) {
      developer.log('Error fetching subscription: $e');
      return null;
    }
  }

  /// Initiate payment for a plan
  Future<PaymentResult> initiatePayment(int planId, String phoneNumber) async {
    try {
      final response = await _dio.post(
        ApiConstants.paySubscription(planId),
        data: {'phone_number': phoneNumber},
      );

      if (response.data['success'] == true) {
        return PaymentResult(
          success: true,
          message: response.data['message'] ?? 'Ombi limetumwa',
          orderId: response.data['data']?['order_id'],
          amount: _parseDouble(response.data['data']?['amount']),
          instructions: response.data['data']?['instructions'],
        );
      }
      return PaymentResult(
        success: false,
        message: response.data['message'] ?? 'Imeshindikana',
      );
    } on DioException catch (e) {
      return PaymentResult(success: false, message: _handleError(e));
    }
  }

  /// Check payment status
  Future<PaymentStatus> checkPaymentStatus(String orderId) async {
    try {
      final response = await _dio.get(ApiConstants.paymentStatus(orderId));
      if (response.data['success'] == true && response.data['data'] != null) {
        return PaymentStatus.fromJson(response.data['data']);
      }
      return PaymentStatus(status: 'failed', message: 'Imeshindikana');
    } catch (e) {
      developer.log('Error checking payment: $e');
      return PaymentStatus(status: 'failed', message: 'Connection error');
    }
  }

  /// Get subscription history
  Future<List<SubscriptionHistory>> getHistory() async {
    try {
      final response = await _dio.get(ApiConstants.subscriptionHistory);
      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => SubscriptionHistory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      developer.log('Error fetching history: $e');
      return [];
    }
  }

  String _handleError(DioException e) {
    if (e.response?.data is Map && e.response?.data['message'] != null) {
      return e.response?.data['message'];
    }
    return 'Connection error. Please try again.';
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// ================== DATA MODELS ==================

class Plan {
  final int id;
  final String name;
  final String slug;
  final String displayName;
  final String description;
  final double price;
  final String priceFormatted;
  final int? durationDays;
  final int dailyTaskLimit;
  final bool hasUnlimitedTasks;
  final double rewardPerTask;
  final String rewardPerTaskFormatted;
  final double minWithdrawal;
  final String minWithdrawalFormatted;
  final double withdrawalFeePercent;
  final int processingDays;
  final List<String> features;
  final String badgeColor;
  final String icon;
  final bool isFree;
  final bool isFeatured;
  final double dailyEarningsEstimate;
  final double monthlyEarningsEstimate;

  Plan({
    required this.id,
    required this.name,
    required this.slug,
    required this.displayName,
    required this.description,
    required this.price,
    required this.priceFormatted,
    this.durationDays,
    required this.dailyTaskLimit,
    required this.hasUnlimitedTasks,
    required this.rewardPerTask,
    required this.rewardPerTaskFormatted,
    required this.minWithdrawal,
    required this.minWithdrawalFormatted,
    required this.withdrawalFeePercent,
    required this.processingDays,
    required this.features,
    required this.badgeColor,
    required this.icon,
    required this.isFree,
    required this.isFeatured,
    required this.dailyEarningsEstimate,
    required this.monthlyEarningsEstimate,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    final featuresList = json['features'] as List? ?? [];
    return Plan(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _parseDouble(json['price']),
      priceFormatted: json['price_formatted']?.toString() ?? 'TZS 0',
      durationDays: json['duration_days'],
      dailyTaskLimit: json['daily_task_limit'] ?? 5,
      hasUnlimitedTasks: json['has_unlimited_tasks'] == true,
      rewardPerTask: _parseDouble(json['reward_per_task']),
      rewardPerTaskFormatted:
          json['reward_per_task_formatted']?.toString() ?? 'TZS 0',
      minWithdrawal: _parseDouble(json['min_withdrawal']),
      minWithdrawalFormatted:
          json['min_withdrawal_formatted']?.toString() ?? 'TZS 0',
      withdrawalFeePercent: _parseDouble(json['withdrawal_fee_percent']),
      processingDays: json['processing_days'] ?? 7,
      features: featuresList.map((f) => f.toString()).toList(),
      badgeColor: json['badge_color']?.toString() ?? '#10b981',
      icon: json['icon']?.toString() ?? 'star',
      isFree: json['is_free'] == true,
      isFeatured: json['is_featured'] == true,
      dailyEarningsEstimate: _parseDouble(json['daily_earnings_estimate']),
      monthlyEarningsEstimate: _parseDouble(json['monthly_earnings_estimate']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory Plan.empty() => Plan(
    id: 0,
    name: 'free',
    slug: 'free',
    displayName: 'Free',
    description: '',
    price: 0,
    priceFormatted: 'TZS 0',
    dailyTaskLimit: 5,
    hasUnlimitedTasks: false,
    rewardPerTask: 100,
    rewardPerTaskFormatted: 'TZS 100',
    minWithdrawal: 10000,
    minWithdrawalFormatted: 'TZS 10,000',
    withdrawalFeePercent: 20,
    processingDays: 7,
    features: [],
    badgeColor: '#10b981',
    icon: 'gift',
    isFree: true,
    isFeatured: false,
    dailyEarningsEstimate: 0,
    monthlyEarningsEstimate: 0,
  );
}

class CurrentSubscription {
  final bool hasSubscription;
  final SubscriptionData? data;
  final String? message;
  final PlanBasic? defaultPlan;

  CurrentSubscription({
    required this.hasSubscription,
    this.data,
    this.message,
    this.defaultPlan,
  });

  factory CurrentSubscription.fromJson(Map<String, dynamic> json) {
    return CurrentSubscription(
      hasSubscription: json['has_subscription'] == true,
      data: json['data'] != null
          ? SubscriptionData.fromJson(json['data'])
          : null,
      message: json['message']?.toString(),
      defaultPlan: json['default_plan'] != null
          ? PlanBasic.fromJson(json['default_plan'])
          : null,
    );
  }
}

class SubscriptionData {
  final int id;
  final PlanBasic plan;
  final String status;
  final String statusLabel;
  final String? startedAt;
  final String? expiresAt;
  final bool isActive;
  final bool isExpired;
  final int daysRemaining;
  final bool isExpiringSoon;
  final int dailyTaskLimit;
  final double rewardPerTask;

  SubscriptionData({
    required this.id,
    required this.plan,
    required this.status,
    required this.statusLabel,
    this.startedAt,
    this.expiresAt,
    required this.isActive,
    required this.isExpired,
    required this.daysRemaining,
    required this.isExpiringSoon,
    required this.dailyTaskLimit,
    required this.rewardPerTask,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      id: json['id'] ?? 0,
      plan: PlanBasic.fromJson(json['plan'] ?? {}),
      status: json['status']?.toString() ?? 'active',
      statusLabel: json['status_label']?.toString() ?? 'Hai',
      startedAt: json['started_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      isActive: json['is_active'] == true,
      isExpired: json['is_expired'] == true,
      daysRemaining: json['days_remaining'] ?? 0,
      isExpiringSoon: json['is_expiring_soon'] == true,
      dailyTaskLimit: json['daily_task_limit'] ?? 5,
      rewardPerTask: _parseDouble(json['reward_per_task']),
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

class PlanBasic {
  final int id;
  final String name;
  final String displayName;
  final String slug;
  final String? badgeColor;
  final String? icon;

  PlanBasic({
    required this.id,
    required this.name,
    required this.displayName,
    required this.slug,
    this.badgeColor,
    this.icon,
  });

  factory PlanBasic.fromJson(Map<String, dynamic> json) {
    return PlanBasic(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      displayName:
          json['display_name']?.toString() ?? json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      badgeColor: json['badge_color']?.toString(),
      icon: json['icon']?.toString(),
    );
  }
}

class PaymentResult {
  final bool success;
  final String message;
  final String? orderId;
  final double? amount;
  final String? instructions;

  PaymentResult({
    required this.success,
    required this.message,
    this.orderId,
    this.amount,
    this.instructions,
  });
}

class PaymentStatus {
  final String status;
  final String? statusLabel;
  final String message;
  final bool isCompleted;
  final bool isPending;
  final bool isFailed;

  PaymentStatus({required this.status, this.statusLabel, required this.message})
    : isCompleted = status == 'completed',
      isPending = status == 'pending',
      isFailed = status == 'failed';

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString(),
      message: json['message']?.toString() ?? '',
    );
  }
}

class SubscriptionHistory {
  final int id;
  final PlanBasic plan;
  final String status;
  final String statusLabel;
  final String? startedAt;
  final String? expiresAt;
  final double amountPaid;
  final bool isActive;
  final String createdAt;

  SubscriptionHistory({
    required this.id,
    required this.plan,
    required this.status,
    required this.statusLabel,
    this.startedAt,
    this.expiresAt,
    required this.amountPaid,
    required this.isActive,
    required this.createdAt,
  });

  factory SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistory(
      id: json['id'] ?? 0,
      plan: PlanBasic.fromJson(json['plan'] ?? {}),
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      startedAt: json['started_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      amountPaid: _parseDouble(json['amount_paid']),
      isActive: json['is_active'] == true,
      createdAt: json['created_at']?.toString() ?? '',
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
