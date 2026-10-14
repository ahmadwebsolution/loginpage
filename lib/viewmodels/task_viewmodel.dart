import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

class TaskViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Loading state helper
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearTasks() {
    _tasks = [];
    _errorMessage = null;
    notifyListeners();
  }

  // --- 1. Fetch / View All Tasks ---
  Future<void> fetchTasks(String token) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      if (token.isEmpty) {
        throw Exception('Authentication token missing. Please login again.');
      }
      _tasks = await _apiService.getTasks(token);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // --- 2. Add New Task ---
  Future<bool> addTask(String token, String title, String description) async {
    _errorMessage = null;

    try {
      if (token.isEmpty) {
        throw Exception('Authentication token missing. Please login again.');
      }

      final newTask = await _apiService.addTask(token, title, description);

      // Agar new task ka valid ID hai toh turant top pe show karein
      if (newTask.id != 0) {
        _tasks.removeWhere((t) => t.id == newTask.id);
        _tasks.insert(0, newTask);
        notifyListeners();
      }

      // Backend se latest tasks list fetch karke synchronize karein
      final freshTasks = await _apiService.getTasks(token);
      _tasks = freshTasks;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // --- 3. Update Existing Task ---
  Future<bool> updateTask(
      String token,
      int id,
      String title,
      String description,
      bool isCompleted,
      ) async {
    _errorMessage = null;

    try {
      if (token.isEmpty) {
        throw Exception('Authentication token missing. Please login again.');
      }

      final updatedTask = await _apiService.updateTask(
        token,
        id,
        title,
        description,
        isCompleted,
      );

      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }

      final freshTasks = await _apiService.getTasks(token);
      _tasks = freshTasks;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // --- 4. Toggle Task Completion Status ---
  Future<bool> toggleTask(String token, TaskModel task) async {
    _errorMessage = null;
    final originalState = task.isCompleted;
    final index = _tasks.indexWhere((t) => t.id == task.id);

    // Optimistic Update: API response ka wait kiye bina UI turant switch karein
    if (index != -1) {
      _tasks[index] = TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        isCompleted: !originalState,
      );
      notifyListeners();
    }

    try {
      await _apiService.toggleTask(token, task.id, !originalState);
      return true;
    } catch (e) {
      // Agar backend par call fail ho to purani state wapas restore karein
      if (index != -1) {
        _tasks[index] = task;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        notifyListeners();
      }
      return false;
    }
  }

  // --- 5. Delete Task ---
  Future<bool> deleteTask(String token, int id) async {
    _errorMessage = null;
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return false;

    // Item store karein aur UI se turant hata dein
    final removedTask = _tasks.removeAt(index);
    notifyListeners();

    try {
      await _apiService.deleteTask(token, id);
      return true;
    } catch (e) {
      // Agar API fail hui to task wapas usi position par laga dein
      _tasks.insert(index, removedTask);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}