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

  Future<Map<String, dynamic>?> getWithdrawalInfo() async {
    try {
      final response = await _dio.get(ApiConstants.withdrawalInfo);

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      developer.log('Error fetching withdrawal info: $e');
      return null;
    }
  }

  Future<String> withdraw({
    required double amount,
    required String method,
    required String accountNumber,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.withdrawals,
        data: {
          'amount': amount,
          'method': method,
          'account_number': accountNumber,
        },
      );

      if (response.data['success'] == true) {
        return response.data['message'] ?? 'Withdrawal request submitted';
      }
      throw response.data['message'] ?? 'Withdrawal failed';
    } on DioException catch (e) {
      throw _handleError(e);
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
}
