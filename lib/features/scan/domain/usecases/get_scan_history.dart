
import '../entities/scan_result.dart';
import '../repositories/scan_repository.dart';

class GetScanHistory {
  final ScanRepository repository;

  GetScanHistory(this.repository);

  Future<List<ScanResult>> call({
    int skip = 0,
    int limit = 20,
  }) {
    return repository.getHistory(
      skip: skip,
      limit: limit,
    );
  }
}
