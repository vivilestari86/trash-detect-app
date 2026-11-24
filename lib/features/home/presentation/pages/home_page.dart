import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../scan/presentation/pages/scan_page.dart';
import '../../../scan/presentation/providers/scan_provider.dart';

import '../../../history/presentation/pages/history_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _openScan() {
    context.read<ScanProvider>().reset();

    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    final pages = [
      _BerandaTab(
        nama: user?.nama ?? 'Pengguna',
        onScan: _openScan,
      ),
      const ScanPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 1 && _selectedIndex != 1) {
            context.read<ScanProvider>().reset();
          }

          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// BERANDA
// ==========================================

class _BerandaTab extends StatelessWidget {
  final String nama;
  final VoidCallback onScan;

  const _BerandaTab({
    required this.nama,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF176B45),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Trash Detect App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sapaan pengguna
              Text(
                'Halo, $nama 👋',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20352A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Yuk, kenali dan pilah sampah mulai dari sekarang.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Banner scan
              _ScanBanner(onScan: onScan),

              const SizedBox(height: 28),

              // Kategori sampah
              const _SectionHeader(
                title: 'Mengenal Jenis Sampah',
                subtitle: 'Kenali dua kategori utama sampah.',
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _CategoryCard(
                      title: 'Organik',
                      description:
                          'Sampah yang mudah terurai secara alami.',
                      examples: 'Daun, kulit buah, sisa makanan.',
                      icon: Icons.eco,
                      color: const Color(0xFF2E8B57),
                      background: const Color(0xFFE8F5E9),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CategoryCard(
                      title: 'Anorganik',
                      description:
                          'Sampah yang umumnya membutuhkan proses pengolahan.',
                      examples: 'Plastik, kaca, logam.',
                      icon: Icons.recycling,
                      color: const Color(0xFF2475B9),
                      background: const Color(0xFFE8F2FC),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Tips pemilahan
              const _SectionHeader(
                title: 'Tips Memilah Sampah',
                subtitle: 'Kebiasaan kecil untuk lingkungan lebih baik.',
              ),

              const SizedBox(height: 14),

              const _TipCard(
                number: '01',
                title: 'Pisahkan berdasarkan jenis',
                description:
                    'Bedakan sampah organik dan anorganik sebelum membuangnya.',
                icon: Icons.delete_sweep_outlined,
              ),

              const SizedBox(height: 10),

              const _TipCard(
                number: '02',
                title: 'Bersihkan sampah daur ulang',
                description:
                    'Bersihkan kemasan plastik atau botol sebelum dikumpulkan.',
                icon: Icons.water_drop_outlined,
              ),

              const SizedBox(height: 10),

              const _TipCard(
                number: '03',
                title: 'Manfaatkan sampah organik',
                description:
                    'Sisa bahan organik tertentu dapat diolah menjadi kompos.',
                icon: Icons.compost,
              ),

              const SizedBox(height: 24),

              // Informasi lingkungan
              _EnvironmentCard(onScan: onScan),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'Mulai dari diri sendiri, untuk bumi yang lebih baik 🌱',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// BANNER SCAN
// ==========================================

class _ScanBanner extends StatelessWidget {
  final VoidCallback onScan;

  const _ScanBanner({
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF176B45),
            Color(0xFF269B62),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF176B45).withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kenali Sampahmu!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pindai gambar sampah dan ketahui kategorinya dengan mudah.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.document_scanner_outlined,
                color: Colors.white,
                size: 55,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                'Mulai Scan Sekarang',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF176B45),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HEADER SECTION
// ==========================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF20352A),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// KARTU KATEGORI
// ==========================================

class _CategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String examples;
  final IconData icon;
  final Color color;
  final Color background;

  const _CategoryCard({
    required this.title,
    required this.description,
    required this.examples,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 27,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Contoh:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            examples,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// KARTU TIPS
// ==========================================

class _TipCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;

  const _TipCard({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8EEE9),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF25804E),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF20352A),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            number,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF91A69A),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// INFORMASI LINGKUNGAN
// ==========================================

class _EnvironmentCard extends StatelessWidget {
  final VoidCallback onScan;

  const _EnvironmentCard({
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F2E8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.public,
            color: Color(0xFF267B4B),
            size: 32,
          ),
          const SizedBox(height: 10),
          const Text(
            'Peduli Lingkungan Dimulai dari Kita',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF205C39),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Memilah sampah merupakan langkah sederhana untuk membantu mengurangi pencemaran dan mendukung pengelolaan sampah yang lebih baik.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Color(0xFF496A53),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}