import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _planInfo;
  String? _currentLockToken;
  int? _activeTaskId;
  bool _isLoading = false;
  String? _error;

  // Cooldown timer
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  List<Task> get tasks => _tasks;
  Map<String, dynamic>? get stats => _stats;
  Map<String, dynamic>? get planInfo => _planInfo;
  String? get currentLockToken => _currentLockToken;
  int? get activeTaskId => _activeTaskId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get cooldownSeconds => _cooldownSeconds;
  bool get isOnCooldown => _cooldownSeconds > 0;

  // Convenience getters from stats
  int get completedToday => _stats?['completed_today'] ?? 0;
  int get dailyLimit => _stats?['daily_limit'] ?? 0;
  int get remainingToday => _stats?['remaining_today'] ?? 0;
  double get rewardPerTask => (_stats?['reward_per_task'] ?? 0).toDouble();

  Future<void> fetchTasks({String filter = 'all'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _taskService.getTasks(filter: filter);
      _tasks = result['tasks'] as List<Task>;
      _stats = result['stats'];
      _planInfo = result['plan_info'];
    } catch (e) {
      _error = e.toString();
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> startTask(int taskId) async {
    try {
      final result = await _taskService.startTask(taskId);
      if (result != null) {
        _currentLockToken = result['lock_token'];
        _activeTaskId = taskId;
        notifyListeners();
      }
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> completeTask(int taskId) async {
    if (_currentLockToken == null) {
      throw 'No active task session';
    }

    try {
      final result = await _taskService.completeTask(
        taskId,
        _currentLockToken!,
      );
      _currentLockToken = null;
      _activeTaskId = null;

      // Start cooldown timer (e.g., 15 seconds between tasks)
      startCooldown(15);

      // Refresh tasks list
      await fetchTasks();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    _cooldownSeconds = seconds;
    notifyListeners();

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        _cooldownSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        _cooldownTimer = null;
      }
    });
  }

  void cancelCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    _cooldownSeconds = 0;
    notifyListeners();
  }

  Future<void> cancelTask() async {
    await _taskService.cancelTask();
    _currentLockToken = null;
    _activeTaskId = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
