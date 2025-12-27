import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/task_model.dart';

class TaskService {
  final Dio _dio = Dio();

  TaskService() {
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
          developer.log('Task API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getTasks({String filter = 'all'}) async {
    try {
      final response = await _dio.get(ApiConstants.tasks);

      if (response.data['success'] == true && response.data['data'] != null) {
        final data = response.data['data'];

        final List<Task> tasks = [];
        if (data['tasks'] != null && data['tasks'] is List) {
          for (var item in data['tasks']) {
            tasks.add(Task.fromJson(item));
          }
        }

        // Filter locally if needed
        List<Task> filteredTasks = tasks;
        if (filter == 'premium') {
          filteredTasks = tasks.where((t) => t.isFeatured).toList();
        } else if (filter == 'free') {
          filteredTasks = tasks.where((t) => !t.isFeatured).toList();
        }

        return {
          'tasks': filteredTasks,
          'activity': data['activity'],
          'stats': data['stats'],
          'plan_info': data['plan_info'],
        };
      }
      return {'tasks': <Task>[]};
    } catch (e) {
      developer.log('Error fetching tasks: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> startTask(int taskId) async {
    try {
      final response = await _dio.post(ApiConstants.startTask(taskId));
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw response.data['message'] ?? 'Failed to start task';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>?> checkTaskStatus(int taskId) async {
    try {
      final response = await _dio.post(ApiConstants.taskStatus(taskId));
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      developer.log('Error checking task status: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> completeTask(
    int taskId,
    String lockToken,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.completeTask(taskId),
        data: {'lock_token': lockToken},
      );
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw response.data['message'] ?? 'Failed to complete task';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> cancelTask() async {
    try {
      await _dio.post(ApiConstants.cancelTask);
    } catch (e) {
      developer.log('Error canceling task: $e');
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
