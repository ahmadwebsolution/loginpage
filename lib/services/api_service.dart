import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import '../models/user_model.dart';

class ApiService {
  Map<String, String> _headers([String? token]) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // --- 1. Register API ---
  Future<UserModel> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('https://awsdemo.co.in/laravel-api-todo/backend/api/register'),
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password, // Laravel validation fix
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserModel.fromJson(data);
    } else {
      if (data['errors'] != null && data['errors'] is Map) {
        final Map<String, dynamic> errors = data['errors'];
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          throw Exception(firstError.first);
        }
      }
      throw Exception(data['message'] ?? 'Registration Failed');
    }
  }

  // --- 2. Login API ---
  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://awsdemo.co.in/laravel-api-todo/backend/api/login'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return UserModel.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Invalid Credentials');
    }
  }

  // --- 3. View All Tasks API ---
  Future<List<TaskModel>> getTasks(String token) async {
    final response = await http.get(
      Uri.parse('https://awsdemo.co.in/laravel-api-todo/backend/api/tasks'),
      headers: _headers(token),
    );

    print("GET TASKS CODE: ${response.statusCode}");
    print("GET TASKS BODY: ${response.body}");

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      List rawList = [];
      if (res is List) {
        rawList = res;
      } else if (res is Map) {
        if (res['data'] is List) {
          rawList = res['data'];
        } else if (res['data'] is Map && res['data']['data'] is List) {
          // Laravel pagination format: data.data
          rawList = res['data']['data'];
        } else if (res['data'] is Map && res['data']['tasks'] is List) {
          rawList = res['data']['tasks'];
        } else if (res['tasks'] is List) {
          rawList = res['tasks'];
        }
      }

      return rawList
          .where((item) => item is Map)
          .map((item) => TaskModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } else {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to load tasks (${response.statusCode})');
      } catch (e) {
        if (e is! FormatException) rethrow;
        throw Exception('Failed to load tasks (${response.statusCode})');
      }
    }
  }

  // --- 4. Add Task API ---
  Future<TaskModel> addTask(String token, String title, String description) async {
    final response = await http.post(
      Uri.parse('https://awsdemo.co.in/laravel-api-todo/backend/api/tasks'),
      headers: _headers(token),
      body: jsonEncode({
        'title': title,
        'description': description,
      }),
    );

    print("ADD TASK CODE: ${response.statusCode}");
    print("ADD TASK BODY: ${response.body}");

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic>? taskData;
      if (data is Map) {
        if (data['data'] is Map) {
          taskData = Map<String, dynamic>.from(data['data']);
        } else if (data['task'] is Map) {
          taskData = Map<String, dynamic>.from(data['task']);
        } else if (data.containsKey('id') || data.containsKey('title')) {
          taskData = Map<String, dynamic>.from(data);
        }
      }

      if (taskData != null) {
        return TaskModel.fromJson(taskData);
      } else {
        // Fallback agar backend ne sirf message return kiya ho
        return TaskModel(
          id: 0,
          title: title,
          description: description,
          isCompleted: false,
        );
      }
    } else {
      if (data is Map && data['errors'] != null && data['errors'] is Map) {
        final Map errors = data['errors'];
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          throw Exception(firstError.first);
        }
      }
      throw Exception(data is Map ? (data['message'] ?? 'Failed to add task (${response.statusCode})') : 'Failed to add task (${response.statusCode})');
    }
  }

  // --- 5. Update Task API ---
  Future<TaskModel> updateTask(String token, int id, String title, String description, bool isCompleted) async {
    final response = await http.put(
      Uri.parse('https://awsdemo.co.in/laravel-api-todo/backend/api/tasks/$id'),
      headers: _headers(token),
      body: jsonEncode({
        'title': title,
        'description': description,
        'is_completed': isCompleted ? 1 : 0,
      }),
    );

    print("UPDATE TASK CODE: ${response.statusCode}");
    print("UPDATE TASK BODY: ${response.body}");

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic>? taskData;
      if (data is Map) {
        if (data['data'] is Map) {
          taskData = Map<String, dynamic>.from(data['data']);
        } else if (data['task'] is Map) {
          taskData = Map<String, dynamic>.from(data['task']);
        } else if (data.containsKey('id') || data.containsKey('title')) {
          taskData = Map<String, dynamic>.from(data);
        }
      }

      if (taskData != null) {
        return TaskModel.fromJson(taskData);
      } else {
        return TaskModel(
          id: id,
          title: title,
          description: description,
          isCompleted: isCompleted,
        );
      }
    } else {
      throw Exception(data is Map ? (data['message'] ?? 'Failed to update task') : 'Failed to update task');
    }
  }

  // --- 6. Toggle Task Status API ---
  Future<TaskModel> toggleTask(String token, int id, bool newStatus) async {
    final response = await http.patch(
      Uri.parse('https://awsdemo.co.in/laravel-api-todo/backend/api/tasks/$id/toggle'),
      headers: _headers(token),
      body: jsonEncode({
        'is_completed': newStatus ? 1 : 0,
      }),
    );

    print("TOGGLE TASK CODE: ${response.statusCode}");
    print("TOGGLE TASK BODY: ${response.body}");

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic>? taskData;
      if (data is Map) {
        if (data['data'] is Map) {
          taskData = Map<String, dynamic>.from(data['data']);
        } else if (data['task'] is Map) {
          taskData = Map<String, dynamic>.from(data['task']);
        } else if (data.containsKey('id') || data.containsKey('title')) {
          taskData = Map<String, dynamic>.from(data);
        }
      }

      if (taskData != null) {
        return TaskModel.fromJson(taskData);
      } else {
        return TaskModel(
          id: id,
          title: '',
          description: '',
          isCompleted: newStatus,
        );
      }
    } else {
      throw Exception(data is Map ? (data['message'] ?? 'Failed to toggle status') : 'Failed to toggle status');
    }
  }

  // --- 7. Delete Task API ---
  Future<void> deleteTask(String token, int id) async {
    final response = await http.delete(
      Uri.parse('https://awsdemo.co.in/laravel-api-todo/backend/api/tasks/$id'),
      headers: _headers(token),
    );

    print("DELETE TASK CODE: ${response.statusCode}");

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete task (${response.statusCode})');
    }
  }
}