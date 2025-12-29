import 'package:flutter/material.dart';
import '../../../models/transaction_model.dart';
import '../services/wallet_service.dart';

class WalletProvider with ChangeNotifier {
  final WalletService _walletService = WalletService();

  List<Transaction> _transactions = [];
  double _balance = 0.0;
  double _totalEarned = 0.0;
  double _totalWithdrawn = 0.0;
  double _todayEarned = 0.0;
  int _pendingWithdrawals = 0;
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  double get balance => _balance;
  double get totalEarned => _totalEarned;
  double get totalWithdrawn => _totalWithdrawn;
  double get todayEarned => _todayEarned;
  int get pendingWithdrawals => _pendingWithdrawals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Convenience getter for available balance
  double get availableBalance => _balance;

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<void> fetchWalletData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final walletData = await _walletService.getWalletData();

      if (walletData != null) {
        _balance = _parseDouble(walletData['balance']);
        _totalEarned = _parseDouble(walletData['total_earned']);
        _totalWithdrawn = _parseDouble(walletData['total_withdrawn']);
        _todayEarned = _parseDouble(walletData['today_earned']);
        _pendingWithdrawals = walletData['pending_withdrawals'] ?? 0;
      }

      _transactions = await _walletService.getTransactions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> withdraw({
    required double amount,
    required String method,
    required String accountNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final message = await _walletService.withdraw(
        amount: amount,
        method: method,
        accountNumber: accountNumber,
      );
      await fetchWalletData(); // Refresh balance
      return message;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
