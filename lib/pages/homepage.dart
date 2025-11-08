import 'package:flutter/material.dart';
// HAPUS SEMUA IMPORT KE HALAMAN LAIN
// (Sudah dihapus sesuai permintaan Anda)

class HomeWayangPage extends StatelessWidget {
  const HomeWayangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFEFBF5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              SizedBox(
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Logo di tengah
                    Center(
                        child: Image.asset(
                      "assets/logo.png",
                      height: 31,
                      // Fallback jika gambar tidak ada
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 31),
                    )),

                    // Avatar di kanan atas
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        child: const CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage("assets/profil.png"),
                          // Fallback jika gambar tidak ada
                          // onBackgroundImageError: (exception, stackTrace) {
                          //   // Kosongkan untuk menghindari error,
                          //   // CircleAvatar akan tampilkan background default
                          // },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ===== WELCOME TEXT =====
              const Center(
                child: Text(
                  "Selamat Datang, Arya",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff4B3425),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ===== BANNER =====
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  "assets/banner.jpg",
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Fallback jika gambar tidak ada
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.grey.shade200,
                    ),
                    child: const Center(
                        child: Text("Gagal memuat banner",
                            style: TextStyle(color: Colors.grey))),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ===== 4 MENU ICON =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _menuItem(
                    context,
                    "assets/icon_scan.png",
                    "Pengenalan\nWayang",
                  ),
                  _menuItem(context, "assets/icon_quiz.png", "Quiz"),
                  _menuItem(
                    context,
                    "assets/icon_dalang.png",
                    "Mencari\nDalang",
                  ),
                  _menuItem(
                      context, "assets/icon_video.png", "Pertunjukan\nWayang"),
                ],
              ),

              const SizedBox(height: 35),

              // ===== Sejarah WAYANG SECTION (MODIFIKASI) =====
              GestureDetector(
                onTap: () {
                  // Arahkan ke halaman daftar sejarah (sudah benar)
                  Navigator.pushNamed(context, '/sejarah_wayang');
                },
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Kisah Sejarah Wayang Kulit",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff4B3425),
                          ),
                        ),
                        Text(
                          "Selengkapnya",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // --- PERUBAHAN UTAMA: DARI CONTAINER MENJADI SCROLL HORIZONTAL ---
                    SizedBox(
                      height: 180, // Tentukan tinggi area scroll
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            // Panggil card baru
                            _buildSejarahCard(
                              context,
                              'assets/mahabarata_banner.jpeg', // Gambar dari request
                              'Kisah Mahabharata',
                            ),
                            // Kartu-kartu dummy agar bisa di-scroll
                            _buildSejarahCard(
                              context,
                              'assets/mahabarata_banner.jpeg', // Ganti dengan aset Anda
                              'Kisah Ramayana',
                            ),
                            _buildSejarahCard(
                              context,
                              'assets/mahabarata_banner.jpeg', // Ganti dengan aset Anda
                              'Cerita Punakawan',
                            ),
                          ],
                        ),
                      ),
                    ),
                    // --- AKHIR PERUBAHAN ---
                  ],
                ),
              ),

              const SizedBox(height: 70),
            ],
          ),
        ),
      ),

      // ===== FLOATING CHATBOT =====
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffE8D4BE),
        onPressed: () {
          // Menggunakan pushNamed ke route '/chatbot'
          Navigator.pushNamed(context, '/chatbot');
        },
        child: Image.asset(
          "assets/icon_robot.png",
          height: 30,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.smart_toy_outlined),
        ),
      ),
    );
  }

  // ===== MENU ITEM COMPONENT =====
  Widget _menuItem(BuildContext context, String icon, String label) {
    return GestureDetector(
      onTap: () {
        // --- SEMUA LOGIKA NAVIGASI DIPERBARUI DI SINI ---

        if (label == "Pengenalan\nWayang") {
          // Menggunakan pushNamed
          // PASTIKAN Anda sudah menambahkan route '/pengenalan' di main.dart
          Navigator.pushNamed(context, '/pengenalan');
        } else if (label == "Quiz") {
          // Menggunakan pushNamed
          Navigator.pushNamed(context, '/quiz');
        } else if (label == "Mencari\nDalang") {
          // Menggunakan pushNamed
          Navigator.pushNamed(context, '/cari_dalang');
        } else if (label == "Pertunjukan\nWayang") {
          // Menggunakan pushNamed
          Navigator.pushNamed(context, '/video');
        }
      },
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0xffF3E7D3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Image.asset(
                icon,
                height: 30,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 30),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xff4B3425),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BARU UNTUK KARTU SEJARAH ---
  Widget _buildSejarahCard(
      BuildContext context, String imagePath, String title) {
    return Container(
      width: 250, // Lebar setiap kartu
      margin: const EdgeInsets.only(right: 16), // Jarak antar kartu
      decoration: BoxDecoration(
        color: const Color(0xffF3E7D3), // Warna background kartu
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            child: Image.asset(
              imagePath,
              height: 120, // Tinggi gambar
              width: double.infinity,
              fit: BoxFit.cover,
              // Fallback jika gambar artikel tidak ada
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
          ),
          // Judul
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff4B3425),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}