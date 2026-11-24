
import 'dart:io';

import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/scan_remote_datasource.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ScanRemoteDataSource remote;

  ScanRepositoryImpl(this.remote);

  @override
  Future<ScanResult> classify(File image) {
    return remote.classify(image);
  }

  @override
  Future<List<ScanResult>> getHistory({
    int skip = 0,
    int limit = 20,
  }) {
    return remote.getHistory(
      skip: skip,
      limit: limit,
    );
  }
}
