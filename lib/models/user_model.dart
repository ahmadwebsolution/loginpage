class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? token;

  UserModel({this.id, this.name, this.email, this.token});

  static String? extractToken(Map<String, dynamic> json) {
    // 1. Direct top-level token
    if (json['token'] is String && (json['token'] as String).isNotEmpty) {
      return json['token'];
    }
    if (json['access_token'] is String && (json['access_token'] as String).isNotEmpty) {
      return json['access_token'];
    }

    // 2. authorization or authorisation object
    final auth = json['authorization'] ?? json['authorisation'];
    if (auth is Map && auth['token'] is String && (auth['token'] as String).isNotEmpty) {
      return auth['token'];
    }

    // 3. Inside 'data' object
    if (json['data'] is Map) {
      final data = json['data'] as Map;
      if (data['token'] is String && (data['token'] as String).isNotEmpty) {
        return data['token'];
      }
      if (data['access_token'] is String && (data['access_token'] as String).isNotEmpty) {
        return data['access_token'];
      }
      final dataAuth = data['authorization'] ?? data['authorisation'];
      if (dataAuth is Map && dataAuth['token'] is String && (dataAuth['token'] as String).isNotEmpty) {
        return dataAuth['token'];
      }
    }

    // 4. Inside 'user' object
    if (json['user'] is Map) {
      final user = json['user'] as Map;
      if (user['token'] is String && (user['token'] as String).isNotEmpty) {
        return user['token'];
      }
      if (user['access_token'] is String && (user['access_token'] as String).isNotEmpty) {
        return user['access_token'];
      }
    }

    return null;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Extract user info
    Map<dynamic, dynamic> userData = json;
    if (json['user'] is Map) {
      userData = json['user'];
    } else if (json['data'] is Map) {
      if (json['data']['user'] is Map) {
        userData = json['data']['user'];
      } else {
        userData = json['data'];
      }
    }

    final rawId = userData['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

    return UserModel(
      id: id,
      name: userData['name']?.toString(),
      email: userData['email']?.toString(),
      token: extractToken(json),
    );
  }
}