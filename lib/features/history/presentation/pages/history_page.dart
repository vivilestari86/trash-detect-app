import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../scan/domain/entities/scan_result.dart';
import '../../../scan/presentation/pages/history_detail_page.dart';
import '../../../scan/presentation/providers/scan_provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const Color primaryColor = Color(0xFF176B45);
  static const Color backgroundColor = Color(0xFFF7F9F7);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ScanProvider>().loadHistory();
      }
    });
  }

  Future<void> _refreshHistory() async {
    await context.read<ScanProvider>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Riwayat Scan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _refreshHistory,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: Consumer<ScanProvider>(
        builder: (context, provider, child) {
          if (provider.isHistoryLoading && provider.history.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          if (provider.historyErrorMessage != null &&
              provider.history.isEmpty) {
            return _HistoryMessage(
              icon: Icons.wifi_off,
              message: provider.historyErrorMessage!,
              buttonText: 'Coba Lagi',
              onPressed: _refreshHistory,
            );
          }

          if (provider.history.isEmpty) {
            return _HistoryMessage(
              icon: Icons.history_rounded,
              message: 'Belum ada riwayat scan.',
              buttonText: 'Muat Ulang',
              onPressed: _refreshHistory,
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshHistory,
            color: primaryColor,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: provider.history.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aktivitas Pemindaian',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF20352A),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${provider.history.length} riwayat pemindaian tersimpan',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final result = provider.history[index - 1];

                return _HistoryCard(result: result);
              },
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// KARTU RIWAYAT
// ==========================================

class _HistoryCard extends StatelessWidget {
  final ScanResult result;

  const _HistoryCard({
    required this.result,
  });

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

    final color = isOrganik
        ? const Color(0xFF2E8B57)
        : const Color(0xFF2878B8);

    final background = isOrganik
        ? const Color(0xFFE8F5EC)
        : const Color(0xFFE8F1FA);

    return Card(
      margin: const EdgeInsets.only(bottom: 13),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE5EAE6),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => HistoryDetailPage(result: result),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _HistoryImage(
                imageUrl: result.imageUrl,
                color: color,
                isOrganik: isOrganik,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sampah ${result.kategori}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF20352A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Colors.black45,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            _formatDate(result.createdAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Keyakinan ${(result.confidence * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// GAMBAR RIWAYAT
// ==========================================

class _HistoryImage extends StatelessWidget {
  final String? imageUrl;
  final Color color;
  final bool isOrganik;

  const _HistoryImage({
    required this.imageUrl,
    required this.color,
    required this.isOrganik,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl!,
        width: 76,
        height: 76,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return SizedBox(
            width: 76,
            height: 76,
            child: Center(
              child: CircularProgressIndicator(
                color: color,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _placeholder();
        },
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isOrganik ? Icons.eco : Icons.recycling,
        color: color,
        size: 32,
      ),
    );
  }
}

// ==========================================
// PESAN RIWAYAT
// ==========================================

class _HistoryMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const _HistoryMessage({
    required this.icon,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F2E8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                size: 45,
                color: const Color(0xFF176B45),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF20352A),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.refresh),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF176B45),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}