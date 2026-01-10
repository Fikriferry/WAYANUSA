import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailDalangPage extends StatelessWidget {
  final String nama;
  final String alamat;
  final String detailAlamat;
  final String gambar;
  final double latitude;
  final double longitude;

  const DetailDalangPage({
    super.key,
    required this.nama,
    required this.alamat,
    required this.detailAlamat,
    required this.gambar,
    required this.latitude,
    required this.longitude,
  });

  // --- LOGIC BUKA MAPS (DIPERBAIKI) ---
  Future<void> _bukaGoogleMaps(BuildContext context) async {
    // Menggunakan skema geo universal
    final Uri googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback jika tidak bisa buka app, buka di browser
        await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka peta: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Palet Warna
    const primaryColor = Color(0xFFD4A373);
    const secondaryColor = Color(0xFF4B3425);
    const bgColor = Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // 1. HEADER PARALLAX MODERN
          SliverAppBar(
            expandedHeight: 350.0,
            floating: false,
            pinned: true,
            backgroundColor: secondaryColor,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // GAMBAR UTAMA
                  Hero(
                    tag: "avatar_${nama}", // Pastikan tag sama dengan halaman list
                    child: Image.network(
                      gambar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 100, color: Colors.grey),
                      ),
                    ),
                  ),
                  // GRADIENT SHADOW (Agar teks/icon terlihat jelas)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. KONTEN BODY
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20), // Efek Overlap ke atas
              child: Container(
                decoration: const BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BARIS NAMA & TITLE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ki Dalang",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                nama,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: secondaryColor,
                                  fontFamily: 'Serif', // Font klasik
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Icon Dekorasi Wayang/Verified
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.verified, color: primaryColor, size: 30),
                        )
                      ],
                    ),

                    const SizedBox(height: 25),
                    const Divider(),
                    const SizedBox(height: 25),

                    // SECTION ALAMAT
                    const Text(
                      "Lokasi & Alamat",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // KARTU ALAMAT
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on, color: Colors.redAccent),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alamat,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  detailAlamat.isNotEmpty ? detailAlamat : "Detail alamat tidak tersedia.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // TOMBOL AKSI UTAMA
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () => _bukaGoogleMaps(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          shadowColor: secondaryColor.withOpacity(0.4),
                        ),
                        icon: const Icon(Icons.map_rounded, color: Colors.white),
                        label: const Text(
                          "Lihat di Google Maps",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // TOMBOL SHARE (OPSIONAL)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur bagikan belum tersedia')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: secondaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.share, color: secondaryColor),
                        label: const Text(
                          "Bagikan Profil",
                          style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}