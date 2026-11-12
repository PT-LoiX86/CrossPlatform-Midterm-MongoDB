import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class MongoService {
  static Future<List<dynamic>> getUsers() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/users');

    debugPrint('Request URL: $uri');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('API error: ${response.statusCode}');
      }

      return jsonDecode(response.body);
    } catch (e, stackTrace) {
      debugPrint('Request failed: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  static Future<void> addUser(String username) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add user: ${response.body}');
    }
  }
}
