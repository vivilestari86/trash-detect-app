
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/scan_provider.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  static const Color primaryColor = Color(0xFF176B45);
  static const Color backgroundColor = Color(0xFFF7F9F7);
  static const Color darkTextColor = Color(0xFF20352A);

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final result = scan.result;

    if (result == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('Hasil Klasifikasi'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Belum ada hasil.'),
        ),
      );
    }

    final Color warna = result.isOrganik
        ? const Color(0xFF2E8B57)
        : const Color(0xFF2878B8);

    final Color warnaCard = result.isOrganik
        ? const Color(0xFFE5F2E8)
        : const Color(0xFFE8F1FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Hasil Klasifikasi'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (scan.image != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5EAE6),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Container(
                      color: const Color(0xFFF1F4F1),
                      alignment: Alignment.center,
                      child: Image.file(
                        scan.image!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            Card(
              color: warnaCard,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Sampah ${result.kategori}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: warna,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tingkat keyakinan '
                      '${(result.confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: darkTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (result.confidence < 0.6) ...[
              const SizedBox(height: 8),
              const Text(
                'Keyakinan model rendah. Coba foto yang lebih jelas, '
                'pencahayaan cukup, dan satu objek saja.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: darkTextColor,
                ),
              ),
            ],

            const SizedBox(height: 16),

            const Text(
              'Probabilitas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkTextColor,
              ),
            ),

            const SizedBox(height: 8),

            for (final e in result.probabilitas.entries) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    e.key,
                    style: const TextStyle(color: darkTextColor),
                  ),
                  Text(
                    '${(e.value * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: e.value.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE0E9E2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 4),

            const Text(
              'Rekomendasi Penanganan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkTextColor,
              ),
            ),

            const SizedBox(height: 8),

            for (final r in result.rekomendasi)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 18,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r,
                        style: const TextStyle(
                          color: darkTextColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  context.read<ScanProvider>().reset();
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Scan Lagi',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
