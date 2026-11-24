
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/usecases/classify_image.dart';
import '../../domain/usecases/get_scan_history.dart';

enum ScanStatus { idle, loading, success, error }

class ScanProvider extends ChangeNotifier {
  final ClassifyImage _classifyImage;
  final GetScanHistory _getScanHistory;
  final ImagePicker _picker = ImagePicker();

  ScanProvider(this._classifyImage, this._getScanHistory);

  ScanStatus _status = ScanStatus.idle;
  File? _image;
  ScanResult? _result;
  String? _errorMessage;

  List<ScanResult> _history = [];
  bool _isHistoryLoading = false;
  String? _historyErrorMessage;

  ScanStatus get status => _status;
  File? get image => _image;
  ScanResult? get result => _result;
  String? get errorMessage => _errorMessage;

  List<ScanResult> get history => _history;
  bool get isHistoryLoading => _isHistoryLoading;
  String? get historyErrorMessage => _historyErrorMessage;

  /// Ambil foto dari kamera atau galeri.
  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 85,
      );

      if (picked == null) return;

      _image = File(picked.path);
      _result = null;
      _errorMessage = null;
      _status = ScanStatus.idle;
    } catch (_) {
      _errorMessage = 'Gagal membuka kamera atau galeri.';
      _status = ScanStatus.error;
    }

    notifyListeners();
  }

  /// Kirim gambar ke backend.
  Future<bool> classify() async {
    final image = _image;
    if (image == null) return false;

    _status = ScanStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _result = await _classifyImage(image);
      _status = ScanStatus.success;

      // Perbarui riwayat setelah prediksi berhasil.
      await loadHistory();

      notifyListeners();
      return true;
    } on Failure catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan yang tidak terduga.';
    }

    _status = ScanStatus.error;
    notifyListeners();
    return false;
  }

  /// Mengambil riwayat scan dari backend.
  Future<void> loadHistory({
    int skip = 0,
    int limit = 20,
  }) async {
    _isHistoryLoading = true;
    _historyErrorMessage = null;
    notifyListeners();

    try {
      _history = await _getScanHistory(
        skip: skip,
        limit: limit,
      );
    } on Failure catch (e) {
      _historyErrorMessage = e.message;
    } catch (_) {
      _historyErrorMessage = 'Gagal mengambil riwayat scan.';
    }

    _isHistoryLoading = false;
    notifyListeners();
  }

  void reset() {
    _image = null;
    _result = null;
    _errorMessage = null;
    _status = ScanStatus.idle;
    notifyListeners();
  }
}
