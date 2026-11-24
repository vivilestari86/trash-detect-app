
import 'package:flutter/material.dart';

import '../../domain/entities/scan_result.dart';

class HistoryDetailPage extends StatelessWidget {
  final ScanResult result;

  const HistoryDetailPage({
    super.key,
    required this.result,
  });

  static const Color primaryColor = Color(0xFF176B45);
  static const Color backgroundColor = Color(0xFFF7F9F7);
  static const Color darkTextColor = Color(0xFF20352A);

  String _formatDate(DateTime? date) {
    if (date == null) return 'Tanggal tidak tersedia';

    final localDate = date.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year;
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final isOrganik = result.isOrganik;
    final resultColor = isOrganik
        ? const Color(0xFF2E8B57)
        : const Color(0xFF2878B8);

    final resultBackground = isOrganik
        ? const Color(0xFFE8F5EC)
        : const Color(0xFFE8F1FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Detail Riwayat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Informasi Hasil Scan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _formatDate(result.createdAt),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 16),

          // Foto hasil scan
          Container(
            height: 230,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5EAE6),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: const Color(0xFFF1F4F1),
                alignment: Alignment.center,
                child: result.imageUrl == null ||
                        result.imageUrl!.isEmpty
                    ? Icon(
                        isOrganik ? Icons.eco : Icons.recycling,
                        size: 60,
                        color: resultColor,
                      )
                    : Image.network(
                        result.imageUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.broken_image_outlined,
                            size: 55,
                            color: Colors.grey.shade500,
                          );
                        },
                      ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Hasil klasifikasi
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: resultBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  isOrganik ? Icons.eco : Icons.recycling,
                  color: resultColor,
                  size: 35,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sampah ${result.kategori}',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                      const Text(
                        'Hasil klasifikasi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Text(
                      'Confidence',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      '${(result.confidence * 100).toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Probabilitas
          const Text(
            'Probabilitas Klasifikasi',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFE5EAE6),
              ),
            ),
            child: Column(
              children: [
                for (final entry in result.probabilitas.entries) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 13,
                            color: darkTextColor,
                          ),
                        ),
                      ),
                      Text(
                        '${(entry.value * 100).toStringAsFixed(2)}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: entry.value.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE8EEE9),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(
                        primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                ],
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Rekomendasi
          const Text(
            'Rekomendasi Penanganan',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFE5EAE6),
              ),
            ),
            child: Column(
              children: [
                for (final recommendation in result.rekomendasi)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 19,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            recommendation,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: darkTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
