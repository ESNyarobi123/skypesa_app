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

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _dio.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Placeholder for avatar update - usually requires MultipartFile
  Future<void> updateAvatar(String imagePath) async {
    // Implementation depends on image picker logic
    // For now, we'll just simulate or leave empty
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
