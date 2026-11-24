
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../error/failure.dart';
import '../storage/token_storage.dart';

class ApiClient {
  final http.Client client;
  final TokenStorage tokenStorage;

  ApiClient({
    required this.client,
    required this.tokenStorage,
  });

  Future<Map<String, String>> _headers({
    bool authenticated = true,
    bool json = false,
  }) async {
    final headers = <String, String>{};

    if (json) {
      headers['Content-Type'] = 'application/json';
    }

    headers['Accept'] = 'application/json';

    if (authenticated) {
      final token = await tokenStorage.getToken();

      if (token == null || token.isEmpty) {
        throw const Failure('Silakan login terlebih dahulu.');
      }

      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<http.Response> get(
    String path, {
    bool authenticated = true,
  }) async {
    try {
      final response = await client
          .get(
            Uri.parse('${ApiConstants.baseUrl}$path'),
            headers: await _headers(
              authenticated: authenticated,
            ),
          )
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on Failure {
      rethrow;
    } on TimeoutException {
      throw const Failure('Server tidak merespons. Coba lagi.');
    } on SocketException {
      throw const Failure('Tidak dapat terhubung ke server.');
    } on http.ClientException {
      throw const Failure('Tidak dapat terhubung ke server.');
    }
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    bool authenticated = true,
    bool json = false,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse('${ApiConstants.baseUrl}$path'),
            headers: await _headers(
              authenticated: authenticated,
              json: json,
            ),
            body: json && body != null
                ? jsonEncode(body)
                : body,
          )
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on Failure {
      rethrow;
    } on TimeoutException {
      throw const Failure('Server tidak merespons. Coba lagi.');
    } on SocketException {
      throw const Failure('Tidak dapat terhubung ke server.');
    } on http.ClientException {
      throw const Failure('Tidak dapat terhubung ke server.');
    }
  }

  Future<http.Response> put(
    String path, {
    Object? body,
  }) async {
    try {
      final response = await client
          .put(
            Uri.parse('${ApiConstants.baseUrl}$path'),
            headers: await _headers(json: true),
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on Failure {
      rethrow;
    } on TimeoutException {
      throw const Failure('Server tidak merespons. Coba lagi.');
    } on SocketException {
      throw const Failure('Tidak dapat terhubung ke server.');
    } on http.ClientException {
      throw const Failure('Tidak dapat terhubung ke server.');
    }
  }

  Future<http.Response> delete(String path) async {
    try {
      final response = await client
          .delete(
            Uri.parse('${ApiConstants.baseUrl}$path'),
            headers: await _headers(),
          )
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on Failure {
      rethrow;
    } on TimeoutException {
      throw const Failure('Server tidak merespons. Coba lagi.');
    } on SocketException {
      throw const Failure('Tidak dapat terhubung ke server.');
    } on http.ClientException {
      throw const Failure('Tidak dapat terhubung ke server.');
    }
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return response;
    }

    String message = 'Terjadi kesalahan pada server.';

    try {
      final body = jsonDecode(response.body);

      if (body is Map && body['detail'] is String) {
        message = body['detail'];
      }
    } catch (_) {}

    if (response.statusCode == 401) {
      throw const Failure(
        'Sesi login berakhir. Silakan login kembali.',
      );
    }

    if (response.statusCode == 409) {
      throw Failure(message);
    }

    if (response.statusCode == 422) {
      throw const Failure(
        'Data yang dimasukkan belum sesuai.',
      );
    }

    throw Failure(message);
  }
}
