
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/scan_provider.dart';
import 'result_page.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  static const Color primaryColor = Color(0xFF176B45);
  static const Color backgroundColor = Color(0xFFF7F9F7);
  static const Color textColor = Color(0xFF20352A);

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final loading = scan.status == ScanStatus.loading;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Scan Sampah',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final compact = availableHeight < 600;

            final spacing = compact ? 10.0 : 15.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                compact ? 10 : 16,
                20,
                compact ? 10 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  const Text(
                    'Deteksi Jenis Sampah',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Ambil foto atau pilih gambar sampah untuk mengetahui kategorinya.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: spacing),

                  // PREVIEW GAMBAR
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE1EAE3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF5F0),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: scan.image == null
                                  ? const _EmptyImage()
                                  : Image.file(
                                      scan.image!,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                scan.image == null
                                    ? Icons.image_outlined
                                    : Icons.check_circle,
                                size: 16,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  scan.image == null
                                      ? 'Belum ada gambar dipilih'
                                      : 'Gambar siap dianalisis',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: spacing),

                  // PILIH SUMBER GAMBAR
                  const Text(
                    'Pilih Sumber Gambar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 9),

                  Row(
                    children: [
                      Expanded(
                        child: _ImageSourceButton(
                          icon: Icons.photo_camera_outlined,
                          label: 'Kamera',
                          onPressed: loading
                              ? null
                              : () => context
                                  .read<ScanProvider>()
                                  .pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ImageSourceButton(
                          icon: Icons.photo_library_outlined,
                          label: 'Galeri',
                          onPressed: loading
                              ? null
                              : () => context
                                  .read<ScanProvider>()
                                  .pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),

                  // PESAN ERROR
                  if (scan.status == ScanStatus.error &&
                      scan.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEEE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.red.shade100,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              scan.errorMessage!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFB3261E),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: spacing),

                  // TOMBOL ANALISIS
                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: ElevatedButton(
                      onPressed: scan.image == null || loading
                          ? null
                          : () => _analisis(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.white70,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: loading
                            ? const Row(
                                key: ValueKey('loading'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 19,
                                    height: 19,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Menganalisis Sampah...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : const Row(
                                key: ValueKey('normal'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.document_scanner_outlined,
                                    size: 21,
                                  ),
                                  SizedBox(width: 9),
                                  Text(
                                    'Analisis Sampah',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: spacing),

                  // TIPS PEMINDAIAN
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(compact ? 10 : 13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F2E8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: primaryColor,
                          size: 22,
                        ),
                        const SizedBox(width: 9),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tips Pemindaian',
                                style: TextStyle(
                                  color: Color(0xFF205C39),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Gunakan gambar yang jelas, pencahayaan cukup, dan pastikan objek sampah terlihat dengan baik.',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF496A53),
                                  fontSize: 11,
                                  height: 1.4,
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
          },
        ),
      ),
    );
  }

  // PROSES ANALISIS
  Future<void> _analisis(BuildContext context) async {
    final provider = context.read<ScanProvider>();

    final berhasil = await provider.classify();

    if (berhasil && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ResultPage(),
        ),
      );
    }
  }
}

// ==========================================
// TAMPILAN KETIKA BELUM ADA GAMBAR
// ==========================================

class _EmptyImage extends StatelessWidget {
  const _EmptyImage();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 58,
          color: Color(0xFF176B45),
        ),
        SizedBox(height: 10),
        Text(
          'Belum Ada Gambar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF20352A),
          ),
        ),
        SizedBox(height: 5),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Ambil foto melalui kamera atau pilih gambar dari galeri.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// TOMBOL SUMBER GAMBAR
// ==========================================

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 21,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF176B45),
        backgroundColor: Colors.white,
        disabledForegroundColor: Colors.grey,
        side: const BorderSide(
          color: Color(0xFF176B45),
          width: 1.2,
        ),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
    );
  }
}
