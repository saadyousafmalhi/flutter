import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class BaseService {
  BaseService({http.Client? client}) : client = client ?? http.Client();

  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  final http.Client client;

  Map<String, String> get _defaultHeaders => const {
    'Accept': 'application/json',
    'User-Agent': 'InterviewApp/1.0 (Flutter; Android)',
  };

  Future<http.Response> get(Uri uri) =>
      client.get(uri, headers: _defaultHeaders);

  Uri url(String path) => Uri.parse('$baseUrl$path');

  T decodeJson<T>(http.Response res) => json.decode(res.body) as T;

  Future<http.Response> patch(
    Uri uri, {
    Object? body,
    Map<String, String>? headers,
  }) {
    return client.patch(uri, headers: headers, body: body);
  }

  void throwOnError(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(
        statusCode: res.statusCode,
        message: 'Request failed: ${res.request?.url}',
        body: res.body,
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? body;
  ApiException({required this.statusCode, required this.message, this.body});
  @override
  String toString() => 'ApiException($statusCode) $message';
}
