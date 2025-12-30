import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/user_model.dart';
import '../../../models/blocked_info_model.dart';

class AuthService {
  final Dio _dio = Dio();

  AuthService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add interceptor to add token to requests and log requests/responses
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          developer.log('REQUEST: ${options.method} ${options.uri}');
          developer.log('REQUEST DATA: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log('RESPONSE: ${response.statusCode}');
          developer.log('RESPONSE DATA: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          developer.log('ERROR: ${error.message}');
          developer.log('ERROR RESPONSE: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  /// Helper method to extract data from API response
  /// Handles multiple response formats:
  /// 1. Direct data: { "token": "...", "user": {...} }
  /// 2. Wrapped data: { "data": { "token": "...", "user": {...} } }
  /// 3. Success wrapper: { "success": true, "data": {...} }
  Map<String, dynamic> _extractResponseData(dynamic responseData) {
    if (responseData == null) {
      throw 'Empty response from server';
    }

    if (responseData is! Map<String, dynamic>) {
      throw 'Invalid response format: expected JSON object';
    }

    // If response has a 'data' key that contains the actual data
    if (responseData.containsKey('data')) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      // If data is not a map, return the original response
      return responseData;
    }

    return responseData;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      developer.log('Attempting login for: $email');

      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      developer.log('Login response status: ${response.statusCode}');
      developer.log('Login response data type: ${response.data.runtimeType}');
      developer.log('Login response data: ${response.data}');

      final data = _extractResponseData(response.data);
      developer.log('Extracted data: $data');

      // Try multiple token field names
      final token =
          data['token'] ?? data['access_token'] ?? data['accessToken'];
      if (token == null) {
        developer.log('Available keys in response: ${data.keys.toList()}');
        throw 'No token received from server. Keys: ${data.keys.toList()}';
      }

      // Extract user data - handle different structures
      dynamic userData = data['user'];
      if (userData == null) {
        // Maybe user data is at root level
        if (data.containsKey('id') && data.containsKey('email')) {
          userData = data;
        } else {
          developer.log(
            'No user data found. Available keys: ${data.keys.toList()}',
          );
          throw 'No user data received from server';
        }
      }

      if (userData is! Map<String, dynamic>) {
        throw 'Invalid user data format';
      }

      final user = User.fromJson(userData);

      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      developer.log('Login successful for user: ${user.email}');
      return {'user': user, 'token': token};
    } on DioException catch (e) {
      developer.log('DioException during login: ${e.message}');
      developer.log('DioException response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      developer.log('General exception during login: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? referralCode,
  }) async {
    try {
      developer.log('Attempting registration for: $email');

      final requestData = {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (referralCode != null && referralCode.isNotEmpty)
          'referral_code': referralCode,
      };

      developer.log('Register request data: $requestData');

      final response = await _dio.post(
        ApiConstants.register,
        data: requestData,
      );

      developer.log('Register response status: ${response.statusCode}');
      developer.log('Register response data: ${response.data}');

      final data = _extractResponseData(response.data);
      developer.log('Extracted data: $data');

      // Try multiple token field names
      final token =
          data['token'] ?? data['access_token'] ?? data['accessToken'];
      if (token == null) {
        developer.log('Available keys in response: ${data.keys.toList()}');
        throw 'No token received from server. Keys: ${data.keys.toList()}';
      }

      // Extract user data - handle different structures
      dynamic userData = data['user'];
      if (userData == null) {
        // Maybe user data is at root level
        if (data.containsKey('id') && data.containsKey('email')) {
          userData = data;
        } else {
          developer.log(
            'No user data found. Available keys: ${data.keys.toList()}',
          );
          throw 'No user data received from server';
        }
      }

      if (userData is! Map<String, dynamic>) {
        throw 'Invalid user data format';
      }

      final user = User.fromJson(userData);

      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      developer.log('Registration successful for user: ${user.email}');

      // Get message from original response if available
      String? message;
      if (response.data is Map && response.data.containsKey('message')) {
        message = response.data['message'];
      }

      return {'user': user, 'token': token, 'message': message};
    } on DioException catch (e) {
      developer.log('DioException during registration: ${e.message}');
      developer.log('DioException response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      developer.log('General exception during registration: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (e) {
      developer.log('Logout error (ignored): $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    }
  }

  Future<User?> getUserProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);

      final data = _extractResponseData(response.data);

      // Check if user data is nested
      if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
        return User.fromJson(data['user'] as Map<String, dynamic>);
      }

      // User data is at root level
      if (data.containsKey('id') && data.containsKey('email')) {
        return User.fromJson(data);
      }

      return null;
    } catch (e) {
      developer.log('Get profile error: $e');
      return null;
    }
  }

  /// Check if the current user is blocked
  /// Returns BlockedInfo with is_blocked status and details
  Future<BlockedInfo> checkBlockedStatus() async {
    try {
      developer.log('=== Checking blocked status ===');

      final response = await _dio.get(ApiConstants.blockedInfo);

      developer.log('Blocked info response status: ${response.statusCode}');
      developer.log('Blocked info response data: ${response.data}');
      developer.log('Response data type: ${response.data.runtimeType}');

      if (response.data == null) {
        developer.log('ERROR: Response data is null');
        return BlockedInfo(isBlocked: false, message: 'No data from server');
      }

      final data = response.data as Map<String, dynamic>;

      // Debug: print all keys
      developer.log('Response keys: ${data.keys.toList()}');
      developer.log('is_blocked value: ${data['is_blocked']}');
      developer.log('is_blocked type: ${data['is_blocked'].runtimeType}');

      final blockedInfo = BlockedInfo.fromJson(data);
      developer.log('=== Parsed BlockedInfo ===');
      developer.log('isBlocked: ${blockedInfo.isBlocked}');
      developer.log('blockedReason: ${blockedInfo.blockedReason}');
      developer.log('blockedAt: ${blockedInfo.blockedAt}');

      return blockedInfo;
    } on DioException catch (e) {
      developer.log('DioException checking blocked status: ${e.message}');
      developer.log('DioException status code: ${e.response?.statusCode}');
      developer.log('DioException response data: ${e.response?.data}');

      // If 403 Forbidden, user might be blocked
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        developer.log('Got 403 - checking if blocked response');
        if (data is Map<String, dynamic>) {
          developer.log('403 response keys: ${data.keys.toList()}');
          final blockedInfo = BlockedInfo.fromJson(data);
          developer.log('403 isBlocked: ${blockedInfo.isBlocked}');
          return blockedInfo;
        }
      }

      // Return not blocked by default on error
      return BlockedInfo(
        isBlocked: false,
        message: 'Could not check status: ${e.message}',
      );
    } catch (e) {
      developer.log('General error checking blocked status: $e');
      return BlockedInfo(
        isBlocked: false,
        message: 'Could not check status: $e',
      );
    }
  }

  /// Request password reset OTP
  /// Sends OTP to user's email address
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      developer.log('Requesting password reset for: $email');

      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );

      developer.log('Forgot password response: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        return {
          'success': response.data['success'] ?? true,
          'message':
              response.data['message'] ??
              'Maelekezo ya kubadilisha password yametumwa kwenye email yako',
        };
      }

      return {
        'success': true,
        'message':
            'Maelekezo ya kubadilisha password yametumwa kwenye email yako',
      };
    } on DioException catch (e) {
      developer.log('Forgot password error: ${e.response?.data}');

      if (e.response?.statusCode == 422) {
        final data = e.response?.data;
        if (data is Map) {
          final errors = data['errors'];
          if (errors is Map && errors.containsKey('email')) {
            throw 'Email haipatikani';
          }
          throw data['message'] ?? 'Email haipatikani';
        }
      }

      throw _handleError(e);
    }
  }

  /// Reset password using OTP
  /// Verifies OTP and sets new password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      developer.log('Resetting password for: $email');

      final response = await _dio.post(
        ApiConstants.resetPassword,
        data: {
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      developer.log('Reset password response: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        return {
          'success': response.data['success'] ?? true,
          'message':
              response.data['message'] ?? 'Password imebadilishwa. Ingia sasa.',
        };
      }

      return {
        'success': true,
        'message': 'Password imebadilishwa. Ingia sasa.',
      };
    } on DioException catch (e) {
      developer.log('Reset password error: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map) {
          throw data['message'] ??
              'Kodi ya uhakiki si sahihi au imeisha muda wake';
        }
        throw 'Kodi ya uhakiki si sahihi au imeisha muda wake';
      }

      if (e.response?.statusCode == 422) {
        final data = e.response?.data;
        if (data is Map) {
          final errors = data['errors'];
          if (errors is Map) {
            if (errors.containsKey('token')) {
              throw 'Kodi ya uhakiki si sahihi';
            }
            if (errors.containsKey('password')) {
              throw 'Password lazima iwe na angalau herufi 6';
            }
            if (errors.containsKey('email')) {
              throw 'Email haipatikani';
            }
          }
          throw data['message'] ?? 'Tafadhali angalia taarifa ulizojaza';
        }
      }

      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    developer.log('Handling DioException: ${e.type}');

    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      developer.log('Error status code: $statusCode');
      developer.log('Error response data: $data');

      if (data is Map) {
        // Try different error message fields
        final message =
            data['message'] ??
            data['error'] ??
            data['errors']?.toString() ??
            (data['errors'] is Map
                ? (data['errors'] as Map).values.first?.toString()
                : null);

        if (message != null) {
          return message.toString();
        }
      }

      // Handle specific status codes
      switch (statusCode) {
        case 401:
          return 'Invalid email or password';
        case 422:
          return 'Validation error. Please check your input.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Server error: $statusCode';
      }
    }

    // Handle network errors
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server took too long to respond. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Connection error. Please check your internet.';
    }

    return 'Connection error. Please check your internet.';
  }
}
