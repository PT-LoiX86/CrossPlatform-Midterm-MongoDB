import 'api_service.dart';

class AuthService {
  static Future<String> login({
    required String username,
    required String password,
  }) async {
    final response = await ApiClient.postJson('/api/auth/login', {
      'username': username,
      'password': password,
    });

    if (response is! Map<String, dynamic> || response['user'] is! Map) {
      throw Exception('Unexpected login response from server.');
    }

    return response['user']['username'].toString();
  }
}
