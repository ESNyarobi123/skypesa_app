import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _service = DashboardService();

  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _error;

  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Convenience getters
  double get walletBalance => _dashboardData?.walletBalance ?? 0;
  int get tasksToday => _dashboardData?.tasksToday ?? 0;
  int get tasksLimit => _dashboardData?.tasksLimit ?? 0;
  int get tasksRemaining => _dashboardData?.tasksRemaining ?? 0;
  double get rewardPerTask => _dashboardData?.rewardPerTask ?? 0;
  String get subscription => _dashboardData?.subscription ?? 'free';
  int get referralCount => _dashboardData?.referralCount ?? 0;

  EarningsData? get earnings => _dashboardData?.earnings;
  double get todayEarnings => _dashboardData?.earnings.today ?? 0;
  double get weekEarnings => _dashboardData?.earnings.thisWeek ?? 0;
  double get monthEarnings => _dashboardData?.earnings.thisMonth ?? 0;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardData = await _service.getDashboardData();
      if (_dashboardData == null) {
        _error = 'Failed to load dashboard data';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _dashboardData = null;
    _error = null;
    notifyListeners();
  }
}
