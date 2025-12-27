import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final data = await _authService.login(email, password);
      _user = data['user'];
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
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      final user = await _authService.getUserProfile();
      if (user != null) {
        _user = user;
      }
    } catch (e) {
      // Token might be invalid or expired
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
