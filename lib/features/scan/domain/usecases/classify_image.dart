import 'dart:io';

import '../entities/scan_result.dart';
import '../repositories/scan_repository.dart';

class ClassifyImage {
  final ScanRepository repository;
  const ClassifyImage(this.repository);

  Future<ScanResult> call(File image) => repository.classify(image);
}
