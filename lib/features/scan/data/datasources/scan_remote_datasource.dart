
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/scan_result_model.dart';

class ScanRemoteDataSource {
  final http.Client client;
  final TokenStorage tokenStorage;

  ScanRemoteDataSource(this.client, this.tokenStorage);

  /// Mengirim gambar ke backend (multipart/form-data, field "file").
  Future<ScanResultModel> classify(File image) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.scanPath}',
    );

    try {
      final token = await tokenStorage.getToken();

      if (token == null || token.isEmpty) {
        throw const Failure('Silakan login terlebih dahulu.');
      }

      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          await http.MultipartFile.fromPath('file', image.path),
        );

      final streamed = await client.send(request).timeout(
        ApiConstants.timeout,
      );

      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ScanResultModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }

      throw Failure(_pesanServer(response));
    } on Failure {
      rethrow;
    } on TimeoutException {
      throw const Failure(
        'Server tidak merespons. Coba lagi beberapa saat.',
      );
    } on SocketException {
      throw const Failure(
        'Tidak dapat terhubung ke server. Pastikan backend menyala dan alamat IP benar.',
      );
    } on http.ClientException {
      throw const Failure(
        'Tidak dapat terhubung ke server.',
      );
    } on FormatException {
      throw const Failure(
        'Respons server tidak sesuai format yang diharapkan.',
      );
    }
  }


  /// Mengambil riwayat scan pengguna yang sedang login.
  Future<List<ScanResultModel>> getHistory({
    int skip = 0,
    int limit = 20,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/scans',
    ).replace(
      queryParameters: {
        'skip': skip.toString(),
        'limit': limit.toString(),
      },
    );

    try {
      final token = await tokenStorage.getToken();

      if (token == null || token.isEmpty) {
        throw const Failure('Silakan login terlebih dahulu.');
      }

      final response = await client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;

        return data
            .map(
              (item) => ScanResultModel.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      }

      throw Failure(_pesanServer(response));
    } on Failure {
      rethrow;
    } on TimeoutException {
      throw const Failure('Server tidak merespons. Coba lagi.');
    } on SocketException {
      throw const Failure('Tidak dapat terhubung ke server.');
    } on http.ClientException {
      throw const Failure('Tidak dapat terhubung ke server.');
    } on FormatException {
      throw const Failure('Format data riwayat tidak valid.');
    }
  }

  String _pesanServer(http.Response r) {
    try {
      final body = jsonDecode(r.body);

      if (body is Map && body['detail'] is String) {
        return body['detail'] as String;
      }
    } catch (_) {}

    return 'Server mengembalikan kesalahan (kode ${r.statusCode}).';
  }
}
