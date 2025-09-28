// lib/services/base_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class BaseService {
  BaseService({http.Client? client, String? base})
    : client = client ?? http.Client(),
      base = base ?? 'https://jsonplaceholder.typicode.com';

  /// Per-service base URL (JSONPlaceholder by default).
  final String base;

  final http.Client client;

  /// Default headers for all requests; services can override/extend.
  Map<String, String> get defaultHeaders => const {
    'Accept': 'application/json',
    'User-Agent': 'InterviewApp/1.0 (Flutter; Android)',
  };

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) {
    return client.get(
      uri,
      headers: {...defaultHeaders, if (headers != null) ...headers},
    );
  }

  /// Build URL relative to this service's base, with optional query params.
  Uri url(String path, {Map<String, String>? query}) {
    final baseUri = Uri.parse(base);
    return Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      path: '${baseUri.path}${path.startsWith('/') ? path : '/$path'}',
      queryParameters: query,
    );
  }

  T decodeJson<T>(http.Response res) => json.decode(res.body) as T;

  Future<http.Response> patch(
    Uri uri, {
    Object? body,
    Map<String, String>? headers,
  }) {
    return client.patch(
      uri,
      headers: {...defaultHeaders, if (headers != null) ...headers},
      body: body,
    );
  }

  Future<http.Response> post(
    Uri uri, {
    Object? body,
    Map<String, String>? headers,
  }) {
    return client.post(
      uri,
      headers: {...defaultHeaders, if (headers != null) ...headers},
      body: body,
    );
  }

  Future<http.Response> deleteReq(Uri uri, {Map<String, String>? headers}) {
    return client.delete(
      uri,
      headers: {
        ...defaultHeaders, // or _defaultHeaders in your file
        if (headers != null) ...headers,
      },
    );
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
