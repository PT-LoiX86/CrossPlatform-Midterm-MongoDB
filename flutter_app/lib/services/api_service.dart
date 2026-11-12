import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import '../utils/api_exception.dart';

class ApiClient {
  static final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 25);

  static Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  static Future<dynamic> get(String path) async {
    try {
      final response = await _client.get(_uri(path)).timeout(_timeout);
      return _decodeResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'The server did not respond in time. Check that the backend is running.',
      );
    } on http.ClientException catch (error) {
      throw ApiException('Network error: ${error.message}');
    }
  }

  static Future<dynamic> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client
          .post(
            _uri(path),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _decodeResponse(response);
    } on TimeoutException {
      throw const ApiException('The server did not respond in time.');
    } on http.ClientException catch (error) {
      throw ApiException('Network error: ${error.message}');
    }
  }

  static Future<dynamic> delete(String path) async {
    try {
      final response = await _client.delete(_uri(path)).timeout(_timeout);
      return _decodeResponse(response);
    } on TimeoutException {
      throw const ApiException('The server did not respond in time.');
    } on http.ClientException catch (error) {
      throw ApiException('Network error: ${error.message}');
    }
  }

  static Future<dynamic> sendMultipart({
    required String method,
    required String path,
    required Map<String, String> fields,
    String? imagePath,
  }) async {
    try {
      final request = http.MultipartRequest(method, _uri(path));
      request.fields.addAll(fields);
      if (imagePath != null) {
        final mimeType =
            lookupMimeType(imagePath) ?? 'application/octet-stream';

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imagePath,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final streamedResponse = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse)
          .timeout(_timeout);
      return _decodeResponse(response);
    } on TimeoutException {
      throw const ApiException('The server did not respond in time.');
    } on http.ClientException catch (error) {
      throw ApiException('Network error: ${error.message}');
    }
  }

  static dynamic _decodeResponse(http.Response response) {
    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(utf8.decode(response.bodyBytes));
      } on FormatException {
        decoded = response.body;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString() ??
                'Request failed (${response.statusCode}).'
          : 'Request failed (${response.statusCode}).';
      throw ApiException(message, statusCode: response.statusCode);
    }

    return decoded;
  }
}
