class ScanResult {
  final int? id;
  final String kategori;
  final double confidence;
  final Map<String, double> probabilitas;
  final List<String> rekomendasi;
  final DateTime? createdAt;
  final String? imageUrl;

  const ScanResult({
    this.id,
    required this.kategori,
    required this.confidence,
    required this.probabilitas,
    required this.rekomendasi,
    this.createdAt,
    this.imageUrl,
  });

  bool get isOrganik => kategori.toLowerCase() == 'organik';
}