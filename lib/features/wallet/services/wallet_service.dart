import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/transaction_model.dart';

class WalletService {
  final Dio _dio = Dio();

  WalletService() {
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
          developer.log('Wallet API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> getWalletData() async {
    try {
      final response = await _dio.get(ApiConstants.wallet);

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      developer.log('Error fetching wallet: $e');
      return null;
    }
  }

  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await _dio.get(ApiConstants.transactions);

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'] is List
            ? response.data['data']
            : response.data['data']['transactions'] ?? [];
        return data.map((json) => Transaction.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      developer.log('Error fetching transactions: $e');
      return [];
    }
  }

  /// Get withdrawal info including balance, min amount, fee, and payment providers
  Future<WithdrawalInfo?> getWithdrawalInfo() async {
    try {
      final response = await _dio.get(ApiConstants.withdrawalInfo);

      if (response.data['success'] == true && response.data['data'] != null) {
        return WithdrawalInfo.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      developer.log('Error fetching withdrawal info: $e');
      return null;
    }
  }

  /// Create a new withdrawal request
  Future<WithdrawalResult> createWithdrawal({
    required double amount,
    required String paymentProvider,
    required String paymentNumber,
    required String paymentName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.withdrawals,
        data: {
          'amount': amount,
          'payment_provider': paymentProvider,
          'payment_number': paymentNumber,
          'payment_name': paymentName,
        },
      );

      if (response.data['success'] == true) {
        return WithdrawalResult(
          success: true,
          message: response.data['message'] ?? 'Ombi lako limepokelewa!',
          data: response.data['data'] != null
              ? WithdrawalData.fromJson(response.data['data'])
              : null,
        );
      }
      return WithdrawalResult(
        success: false,
        message: response.data['message'] ?? 'Withdrawal failed',
      );
    } on DioException catch (e) {
      return WithdrawalResult(
        success: false,
        message: _handleError(e),
        errors: _extractErrors(e),
      );
    }
  }

  /// Get list of user's withdrawals
  Future<WithdrawalListResult> getWithdrawals({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.withdrawals,
        queryParameters: {'page': page},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        final meta = response.data['meta'];
        return WithdrawalListResult(
          withdrawals: data
              .map((json) => WithdrawalData.fromJson(json))
              .toList(),
          currentPage: meta?['current_page'] ?? 1,
          lastPage: meta?['last_page'] ?? 1,
          total: meta?['total'] ?? 0,
        );
      }
      return WithdrawalListResult(withdrawals: []);
    } catch (e) {
      developer.log('Error fetching withdrawals: $e');
      return WithdrawalListResult(withdrawals: []);
    }
  }

  /// Get single withdrawal details
  Future<WithdrawalData?> getWithdrawal(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.withdrawals}/$id');

      if (response.data['success'] == true && response.data['data'] != null) {
        return WithdrawalData.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      developer.log('Error fetching withdrawal: $e');
      return null;
    }
  }

  /// Cancel a pending withdrawal
  Future<WithdrawalResult> cancelWithdrawal(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.withdrawals}/$id');

      return WithdrawalResult(
        success: response.data['success'] == true,
        message: response.data['message'] ?? 'Ombi limefutwa',
      );
    } on DioException catch (e) {
      return WithdrawalResult(success: false, message: _handleError(e));
    }
  }

  // Legacy method for backward compatibility
  Future<String> withdraw({
    required double amount,
    required String method,
    required String accountNumber,
  }) async {
    final result = await createWithdrawal(
      amount: amount,
      paymentProvider: _convertMethodToProvider(method),
      paymentNumber: accountNumber,
      paymentName: 'Account Holder',
    );
    if (result.success) {
      return result.message;
    }
    throw result.message;
  }

  String _convertMethodToProvider(String method) {
    switch (method.toLowerCase()) {
      case 'm-pesa':
        return 'mpesa';
      case 'tigo pesa':
        return 'tigopesa';
      case 'airtel money':
        return 'airtelmoney';
      case 'halopesa':
        return 'halopesa';
      default:
        return 'mpesa';
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        return e.response?.data['message'];
      }
      return 'Server error: ${e.response?.statusCode}';
    }
    return 'Connection error. Please check your internet.';
  }

  Map<String, List<String>>? _extractErrors(DioException e) {
    if (e.response?.data is Map && e.response?.data['errors'] != null) {
      final errors = e.response?.data['errors'] as Map<String, dynamic>;
      return errors.map(
        (key, value) =>
            MapEntry(key, (value as List).map((e) => e.toString()).toList()),
      );
    }
    return null;
  }
}

/// Payment provider model
class PaymentProvider {
  final String id;
  final String name;
  final String color;

  PaymentProvider({required this.id, required this.name, required this.color});

  factory PaymentProvider.fromJson(Map<String, dynamic> json) {
    return PaymentProvider(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      color: json['color']?.toString() ?? '#000000',
    );
  }
}

/// Withdrawal info model
class WithdrawalInfo {
  final double balance;
  final double pendingWithdrawal;
  final double minWithdrawal;
  final double withdrawalFeePercent;
  final bool canWithdraw;
  final int pendingWithdrawalsCount;
  final String userName;
  final String userPhone;
  final List<PaymentProvider> paymentProviders;

  WithdrawalInfo({
    required this.balance,
    required this.pendingWithdrawal,
    required this.minWithdrawal,
    required this.withdrawalFeePercent,
    required this.canWithdraw,
    required this.pendingWithdrawalsCount,
    required this.userName,
    required this.userPhone,
    required this.paymentProviders,
  });

  factory WithdrawalInfo.fromJson(Map<String, dynamic> json) {
    final providers = json['payment_providers'] as List? ?? [];
    return WithdrawalInfo(
      balance: _parseDouble(json['balance']),
      pendingWithdrawal: _parseDouble(json['pending_withdrawal']),
      minWithdrawal: _parseDouble(json['min_withdrawal']),
      withdrawalFeePercent: _parseDouble(json['withdrawal_fee_percent']),
      canWithdraw: json['can_withdraw'] == true,
      pendingWithdrawalsCount: json['pending_withdrawals_count'] ?? 0,
      userName: json['user_name']?.toString() ?? '',
      userPhone: json['user_phone']?.toString() ?? '',
      paymentProviders: providers
          .map((p) => PaymentProvider.fromJson(p))
          .toList(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Calculate the fee for a given amount
  double calculateFee(double amount) {
    return amount * (withdrawalFeePercent / 100);
  }

  /// Calculate net amount after fee
  double calculateNetAmount(double amount) {
    return amount - calculateFee(amount);
  }
}

/// Withdrawal data model
class WithdrawalData {
  final int id;
  final String reference;
  final double amount;
  final double fee;
  final double netAmount;
  final String paymentProvider;
  final String paymentNumber;
  final String paymentName;
  final String status;
  final String? statusLabel;
  final int? delayHours;
  final String? processableAt;
  final bool isFrozen;
  final String createdAt;

  WithdrawalData({
    required this.id,
    required this.reference,
    required this.amount,
    required this.fee,
    required this.netAmount,
    required this.paymentProvider,
    required this.paymentNumber,
    required this.paymentName,
    required this.status,
    this.statusLabel,
    this.delayHours,
    this.processableAt,
    this.isFrozen = false,
    required this.createdAt,
  });

  factory WithdrawalData.fromJson(Map<String, dynamic> json) {
    return WithdrawalData(
      id: json['id'] ?? 0,
      reference: json['reference']?.toString() ?? '',
      amount: _parseDouble(json['amount']),
      fee: _parseDouble(json['fee']),
      netAmount: _parseDouble(json['net_amount']),
      paymentProvider: json['payment_provider']?.toString() ?? '',
      paymentNumber: json['payment_number']?.toString() ?? '',
      paymentName: json['payment_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString(),
      delayHours: json['delay_hours'],
      processableAt: json['processable_at']?.toString(),
      isFrozen: json['is_frozen'] == true,
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

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isApproved => status == 'approved';
  bool get isPaid => status == 'paid';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
  bool get canCancel => isPending && !isFrozen;
}

/// Withdrawal result model
class WithdrawalResult {
  final bool success;
  final String message;
  final WithdrawalData? data;
  final Map<String, List<String>>? errors;

  WithdrawalResult({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });
}

/// Withdrawal list result model
class WithdrawalListResult {
  final List<WithdrawalData> withdrawals;
  final int currentPage;
  final int lastPage;
  final int total;

  WithdrawalListResult({
    required this.withdrawals,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });
}
