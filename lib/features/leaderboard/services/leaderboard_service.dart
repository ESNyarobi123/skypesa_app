import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/user_model.dart';

class LeaderboardService {
  final Dio _dio = Dio();

  LeaderboardService() {
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
          developer.log('Leaderboard API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getLeaderboard({
    String period = 'weekly',
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.leaderboard,
        queryParameters: {'period': period},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final data = response.data['data'];

        final List<LeaderboardEntry> entries = [];
        if (data['leaderboard'] != null && data['leaderboard'] is List) {
          for (var item in data['leaderboard']) {
            entries.add(LeaderboardEntry.fromJson(item));
          }
        }

        MyRank? myRank;
        if (data['my_rank'] != null &&
            data['my_rank'] is Map<String, dynamic>) {
          myRank = MyRank.fromJson(data['my_rank']);
        }

        return {
          'entries': entries,
          'period': data['period'] ?? period,
          'myRank': myRank,
        };
      }
      return {
        'entries': <LeaderboardEntry>[],
        'period': period,
        'myRank': null,
      };
    } catch (e) {
      developer.log('Error fetching leaderboard: $e');
      return {
        'entries': <LeaderboardEntry>[],
        'period': period,
        'myRank': null,
      };
    }
  }
}
