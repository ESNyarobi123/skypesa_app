import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/plan_model.dart';

class PlanService {
  final Dio _dio = Dio();

  PlanService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

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
      ),
    );
  }

  Future<List<Plan>> getPlans() async {
    try {
      final response = await _dio.get(ApiConstants.plans);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Plan.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Plan?> getCurrentSubscription() async {
    try {
      final response = await _dio.get(ApiConstants.currentSubscription);
      if (response.data['data'] == null) return null;
      return Plan.fromJson(response.data['data']['plan']);
    } catch (e) {
      return null;
    }
  }

  Future<String> subscribe(int planId) async {
    try {
      final response = await _dio.post(
        ApiConstants.paySubscription(planId.toString()),
      );
      return response.data['message'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> paySubscription(int planId, String phoneNumber) async {
    try {
      final response = await _dio.post(
        ApiConstants.paySubscription(planId.toString()),
        data: {'phone_number': phoneNumber},
      );
      return response.data['message']; // Usually "Payment initiated"
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
