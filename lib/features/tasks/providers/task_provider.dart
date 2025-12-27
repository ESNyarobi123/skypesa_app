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

  List<Task> get tasks => _tasks;
  Map<String, dynamic>? get stats => _stats;
  Map<String, dynamic>? get planInfo => _planInfo;
  String? get currentLockToken => _currentLockToken;
  int? get activeTaskId => _activeTaskId;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
      // Refresh tasks list
      await fetchTasks();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
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
}
