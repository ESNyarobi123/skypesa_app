import 'package:flutter/material.dart';
import '../services/plan_service.dart';

class PlanProvider with ChangeNotifier {
  final PlanService _planService = PlanService();
  List<Plan> _plans = [];
  CurrentSubscription? _subscription;
  bool _isLoading = false;
  String? _error;

  List<Plan> get plans => _plans;
  CurrentSubscription? get subscription => _subscription;
  Plan? get currentPlan => _subscription?.data != null
      ? _plans.firstWhere(
          (p) => p.slug == _subscription?.data?.plan.slug,
          orElse: () => _plans.isNotEmpty ? _plans.first : Plan.empty(),
        )
      : null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPlans() async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _planService.getPlans(),
        _planService.getCurrentSubscription(),
      ]);
      _plans = results[0] as List<Plan>;
      _subscription = results[1] as CurrentSubscription?;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<PaymentResult> initiatePayment(int planId, String phoneNumber) async {
    _setLoading(true);
    try {
      final result = await _planService.initiatePayment(planId, phoneNumber);
      _setLoading(false);
      return result;
    } catch (e) {
      _setLoading(false);
      return PaymentResult(success: false, message: e.toString());
    }
  }

  Future<PaymentStatus> checkPaymentStatus(String orderId) async {
    return await _planService.checkPaymentStatus(orderId);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
