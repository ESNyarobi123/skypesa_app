import 'package:flutter/material.dart';
import '../../../models/plan_model.dart';
import '../services/plan_service.dart';

class PlanProvider with ChangeNotifier {
  final PlanService _planService = PlanService();
  List<Plan> _plans = [];
  Plan? _currentPlan;
  bool _isLoading = false;
  String? _error;

  List<Plan> get plans => _plans;
  Plan? get currentPlan => _currentPlan;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPlans() async {
    _setLoading(true);
    try {
      _plans = await _planService.getPlans();
      _currentPlan = await _planService.getCurrentSubscription();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> subscribe(int planId) async {
    _setLoading(true);
    try {
      await _planService.subscribe(planId);
      await fetchPlans(); // Refresh current plan
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> paySubscription(int planId, String phoneNumber) async {
    _setLoading(true);
    try {
      await _planService.paySubscription(planId, phoneNumber);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
