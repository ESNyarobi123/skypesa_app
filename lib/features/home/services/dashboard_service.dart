import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/user_model.dart';

class DashboardService {
  final Dio _dio = Dio();

  DashboardService() {
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
          developer.log('Dashboard API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<DashboardData?> getDashboardData() async {
    try {
      final response = await _dio.get(ApiConstants.dashboard);

      if (response.data['success'] == true && response.data['data'] != null) {
        return DashboardData.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      developer.log('Error fetching dashboard: $e');
      return null;
    }
  }
}
