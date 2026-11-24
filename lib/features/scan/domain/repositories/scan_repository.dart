
import 'dart:io';

import '../entities/scan_result.dart';

abstract class ScanRepository {
  Future<ScanResult> classify(File image);

  Future<List<ScanResult>> getHistory({
    int skip = 0,
    int limit = 20,
  });
}
