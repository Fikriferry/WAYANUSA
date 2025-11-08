import 'package:flutter/material.dart';
// import 'artikel_detail_page.dart'; // Import halaman detail --> SEKARANG TIDAK PERLU LAGI

class SejarahWayangPage extends StatelessWidget {
  const SejarahWayangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Tombol kembali
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Kisah Sejarah Wayang',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari Kisah',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
            ),
            const SizedBox(height: 20),

            // Daftar Artikel
            // Kita panggil 3x untuk simulasi daftar
            _buildArticleCard(context),
            _buildArticleCard(context),
            _buildArticleCard(context),
          ],
        ),
      ),
    );
  }

  // Widget untuk satu kartu artikel
  Widget _buildArticleCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke Halaman Detail (Page 2)
        // --- PERUBAHAN DI SINI ---
        // Menggunakan pushNamed.
        Navigator.pushNamed(context, '/sejarah_detail');
        // --- AKHIR PERUBAHAN ---
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Artikel
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                'assets/mahabarata_banner.jpeg',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  child: const Center(child: Text('Gagal memuat gambar')),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Judul Artikel
            const Text(
              'Kisah Mahabharata dalam Wayang: Ringkasan & Pesan Moral',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),

            // Sumber Artikel
            const Text(
              'Wayang Indonesia',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}