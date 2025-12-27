import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../services/leaderboard_service.dart';

class LeaderboardProvider with ChangeNotifier {
  final LeaderboardService _service = LeaderboardService();

  List<LeaderboardEntry> _entries = [];
  MyRank? _myRank;
  String _currentPeriod = 'weekly';
  bool _isLoading = false;
  String? _error;

  List<LeaderboardEntry> get entries => _entries;
  MyRank? get myRank => _myRank;
  String get currentPeriod => _currentPeriod;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLeaderboard({String period = 'weekly'}) async {
    _isLoading = true;
    _error = null;
    _currentPeriod = period;
    notifyListeners();

    try {
      final result = await _service.getLeaderboard(period: period);
      _entries = result['entries'] as List<LeaderboardEntry>;
      _myRank = result['myRank'] as MyRank?;
      _currentPeriod = result['period'] as String;
    } catch (e) {
      _error = e.toString();
      _entries = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _entries = [];
    _myRank = null;
    _error = null;
    notifyListeners();
  }
}
