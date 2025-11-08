import 'package:flutter/material.dart';

class ArtikelDetailPage extends StatelessWidget {
  const ArtikelDetailPage({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Artikel
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                'assets/mahabharata_banner.jpg', // <-- PASTIKAN GAMBAR INI ADA
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  child: const Center(child: Text('Gagal memuat gambar')),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Konten Artikel (Teks dari mockup Anda)
            const Text(
              'Mahabharata berkisah tentang persaingan antara dua keluarga bangsawan, Pandawa dan Kurawa, dalam memperebutkan kekuasaan atas Kerajaan Hastinapura. Cerita diawali dari keturunan Raja Santanu yang memiliki dua istri, Dewi Gangga dan Satyawati. Dari Dewi Gangga lahir Bisma, seorang ksatria yang bersumpah untuk tidak menikah demi menjaga tahta Hastinapura. Sementara dari Satyawati lahir dua putra, Citranggada dan Wicitrawirya.\n\n'
              'Setelah kematian mereka, keturunan berikutnya adalah Dretarastra, Pandu, dan Widura. Dretarastra yang buta menjadi ayah dari seratus anak Kurawa, sedangkan Pandu memiliki lima putra yang dikenal sebagai Pandawa.\n\n'
              'Puncak konflik terjadi ketika Duryodana, pemimpin Kurawa, menantang Yudistira dalam permainan dadu. Kekalahan Pandawa memaksa mereka untuk menjalani pengasingan selama 12 tahun dan menyamar selama 1 tahun berikutnya. Setelah masa pengasingan, terjadi Perang Bharatayudha di Kurukshetra yang berakhir dengan kemenangan Pandawa meski harus kehilangan banyak kerabat.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6, // Jarak antar baris
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}