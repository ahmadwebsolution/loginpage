import 'package:flutter_test/flutter_test.dart';
import 'package:loginpage/models/task_model.dart';
import 'package:loginpage/models/user_model.dart';

void main() {
  group('TaskModel Unit Tests', () {
    test('TaskModel.fromJson parses standard JSON correctly', () {
      final json = {
        'id': 101,
        'title': 'Test Title',
        'description': 'Test Description',
        'is_completed': 1,
      };

      final task = TaskModel.fromJson(json);

      expect(task.id, 101);
      expect(task.title, 'Test Title');
      expect(task.description, 'Test Description');
      expect(task.isCompleted, true);
    });

    test('TaskModel.fromJson safely handles null ID and string status', () {
      final json = {
        'id': null,
        'title': 'No ID Task',
        'description': 'Desc',
        'status': 'completed',
      };

      final task = TaskModel.fromJson(json);

      expect(task.id, 0);
      expect(task.title, 'No ID Task');
      expect(task.isCompleted, true);
    });

    test('TaskModel.toJson formats correct map', () {
      final task = TaskModel(
        id: 5,
        title: 'Meeting',
        description: 'Team sync',
        isCompleted: false,
      );

      final map = task.toJson();

      expect(map['title'], 'Meeting');
      expect(map['description'], 'Team sync');
      expect(map['is_completed'], 0);
    });
  });

  group('UserModel Unit Tests', () {
    test('UserModel.extractToken extracts from direct token key', () {
      final json = {
        'token': 'bearer_token_123',
        'user': {'id': 1, 'name': 'John', 'email': 'john@test.com'}
      };

      final user = UserModel.fromJson(json);

      expect(user.token, 'bearer_token_123');
      expect(user.name, 'John');
    });

    test('UserModel.extractToken extracts from authorization object', () {
      final json = {
        'authorization': {
          'token': 'jwt_auth_token_456',
          'type': 'bearer',
        },
        'data': {'id': 2, 'name': 'Alice', 'email': 'alice@test.com'}
      };

      final user = UserModel.fromJson(json);

      expect(user.token, 'jwt_auth_token_456');
      expect(user.name, 'Alice');
    });

    test('UserModel.extractToken extracts from data.token', () {
      final json = {
        'data': {
          'token': 'nested_data_token_789',
          'user': {'id': 3, 'name': 'Bob', 'email': 'bob@test.com'}
        }
      };

      final user = UserModel.fromJson(json);

      expect(user.token, 'nested_data_token_789');
      expect(user.name, 'Bob');
    });
  });
}
