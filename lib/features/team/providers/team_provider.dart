import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../services/team_service.dart';

class TeamProvider with ChangeNotifier {
  final TeamService _teamService = TeamService();

  ReferralData? _referralData;
  List<Map<String, dynamic>> _referralUsers = [];
  bool _isLoading = false;
  String? _error;

  ReferralData? get referralData => _referralData;
  List<Map<String, dynamic>> get referralUsers => _referralUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Convenience getters
  String get referralCode => _referralData?.referralCode ?? '';
  String get referralLink => _referralData?.referralLink ?? '';
  int get totalReferrals => _referralData?.totalReferrals ?? 0;
  int get activeReferrals => _referralData?.activeReferrals ?? 0;
  double get totalEarnings => _referralData?.totalEarnings ?? 0;
  String get shareMessage => _referralData?.shareMessage ?? '';

  Future<void> fetchReferralData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _referralData = await _teamService.getReferralData();
      _referralUsers = await _teamService.getReferralUsers();

      if (_referralData == null) {
        _error = 'Failed to load referral data';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _referralData = null;
    _referralUsers = [];
    _error = null;
    notifyListeners();
  }
}
