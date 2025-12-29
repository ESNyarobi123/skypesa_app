import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../models/blocked_info_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  BlockedInfo? _blockedInfo;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get isAuthenticated => _user != null;
  BlockedInfo? get blockedInfo => _blockedInfo;
  bool get isBlocked => _blockedInfo?.isBlocked ?? false;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final data = await _authService.login(email, password);
      _user = data['user'];
      _error = null;

      // Check if user is blocked after login
      await checkBlockedStatus();

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? referralCode,
  }) async {
    _setLoading(true);
    try {
      final data = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        referralCode: referralCode,
      );
      _user = data['user'];
      _successMessage = data['message'];
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _blockedInfo = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      final user = await _authService.getUserProfile();
      if (user != null) {
        _user = user;
        // Also check blocked status when checking auth
        await checkBlockedStatus();
      }
    } catch (e) {
      // Token might be invalid or expired
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if user is blocked
  /// This can be called periodically or after specific actions
  Future<BlockedInfo> checkBlockedStatus() async {
    try {
      debugPrint('AuthProvider: Starting blocked status check...');
      _blockedInfo = await _authService.checkBlockedStatus();
      debugPrint(
        'AuthProvider: Blocked status result - isBlocked: ${_blockedInfo?.isBlocked}',
      );
      debugPrint(
        'AuthProvider: Blocked reason: ${_blockedInfo?.blockedReason}',
      );
      notifyListeners();
      return _blockedInfo!;
    } catch (e) {
      debugPrint('AuthProvider: Error checking blocked status: $e');
      _blockedInfo = BlockedInfo(isBlocked: false);
      notifyListeners();
      return _blockedInfo!;
    }
  }

  /// Clear blocked info (useful when user gets unblocked)
  void clearBlockedInfo() {
    _blockedInfo = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
