import '../../domain/entities/scan_result.dart';

class ScanResultModel extends ScanResult {
  const ScanResultModel({
    super.id,
    required super.kategori,
    required super.confidence,
    required super.probabilitas,
    required super.rekomendasi,
    super.createdAt,
    super.imageUrl,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    final prob = (json['probabilitas'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, (v as num).toDouble()));

    return ScanResultModel(
      id: json['id'] as int?,
      kategori: json['kategori'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      probabilitas: prob,
      rekomendasi: (json['rekomendasi'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      imageUrl: json['image_url'] as String?,
    );
  }
}