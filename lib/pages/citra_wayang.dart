import 'package:flutter/material.dart';

class PengenalanPage extends StatefulWidget {
  const PengenalanPage({super.key});

  @override
  State<PengenalanPage> createState() => _PengenalanPageState();
}

class _PengenalanPageState extends State<PengenalanPage> {
  // 0 = Ambil Gambar, 1 = Upload Foto
  int _currentTab = 0;

  // Variabel state untuk menyimpan hasil identifikasi
  // Awalnya null (belum ada hasil)
  Map<String, String>? _wayangData;
  String? _imagePath;

  // --- FUNGSI SIMULASI ---
  // Ini adalah fungsi dummy yang akan kita panggil
  // untuk berpura-pura berhasil mengidentifikasi wayang.
  void _startIdentificationSimulation() {
    // Tampilkan loading (opsional)
    // ...

    // Set state dengan data dummy (pura-pura)
    setState(() {
      // Ganti path ini dengan path gambar wayang di assets Anda
      _imagePath =
          'assets/arjuna.png'; // <-- PENTING: Tambahkan gambar ini ke assets
      _wayangData = {
        'nama': 'Arjuna',
        'asal': 'Kisah Mahabharata',
        'sejarah':
            'Salah satu anggota Pandawa Lima, putra Pandu dan Kunti.\n\n'
            'Arjuna merupakan tokoh wayang yang memiliki watak cerdik, sopan, pandai, teliti, pendiam, bijaksana, dan melindungi yang lemah.\n\n'
            'Arjuna memiliki sejumlah nama dan julukan, seperti Permadi, Janaka, Parta, Dananjaya, dan KumbaLali.',
      };
    });
  }

  // Fungsi untuk mereset state ke awal
  void _resetState() {
    setState(() {
      _wayangData = null;
      _imagePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengenalan Wayang'),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      backgroundColor: const Color(0xFFF4F4F4), // Latar belakang abu-abu muda
      body: Column(
        children: [
          // 1. Custom Tab Bar (Ambil Gambar / Upload Foto)
          _buildTabBar(),

          // 2. Konten Utama (Kamera, Upload, atau Hasil)
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _wayangData != null
                  ? _buildResultWidget() // Tampilkan hasil jika data ada
                  : _buildContent(), // Tampilkan konten tab jika data kosong
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk membuat Tab Bar
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem("Ambil Gambar", 0),
          _buildTabItem("Upload Foto", 1),
        ],
      ),
    );
  }

  // Widget untuk satu item di Tab Bar
  Widget _buildTabItem(String title, int index) {
    bool isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTab = index;
          _resetState(); // Reset hasil saat ganti tab
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB6783D) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Menampilkan konten berdasarkan tab yang dipilih
  Widget _buildContent() {
    if (_currentTab == 0) {
      return _buildCameraMockup();
    } else {
      return _buildUploadMockup();
    }
  }

  // Tampilan Mockup untuk "Ambil Gambar"
  Widget _buildCameraMockup() {
    return Container(
      key: const ValueKey('camera'), // Key untuk animasi
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Tampilan pura-pura feed kamera
          const Center(
            child: Icon(Icons.videocam_off, color: Colors.white30, size: 100),
          ),
          Positioned(
            bottom: 40,
            child: GestureDetector(
              onTap: () {
                // --- NANTI: Panggil logika kamera di sini ---
                // await ImagePicker().pickImage(source: ImageSource.camera);
                // ... setelah dapat gambar, kirim ke server / model ML ...

                // Untuk sekarang, kita panggil simulasi
                _startIdentificationSimulation();
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tampilan Mockup untuk "Upload Foto"
  Widget _buildUploadMockup() {
    return Container(
      key: const ValueKey('upload'), // Key untuk animasi
      padding: const EdgeInsets.all(32.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_file, size: 100, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          const Text(
            'Unggah gambar wayang',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ambil gambar dari galeri Anda untuk diidentifikasi.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.image_search, color: Colors.white),
            label: const Text(
              'Pilih dari Galeri',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB6783D),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              // --- NANTI: Panggil logika file picker di sini ---
              // await ImagePicker().pickImage(source: ImageSource.gallery);
              // ... setelah dapat gambar, kirim ke server / model ML ...

              // Untuk sekarang, kita panggil simulasi
              _startIdentificationSimulation();
            },
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan HASIL IDENTIFIKASI
  Widget _buildResultWidget() {
    // Tampilkan error jika data tidak valid (seharusnya tidak terjadi)
    if (_imagePath == null || _wayangData == null) {
      return const Center(child: Text('Terjadi kesalahan'));
    }

    return Container(
      key: const ValueKey('result'), // Key untuk animasi
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Hasil
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  _imagePath!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Error builder jika asset tidak ditemukan
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      child: Center(
                        child: Text(
                          "Gambar tidak ditemukan.\nPastikan Anda menambahkan\n$_imagePath\ndi pubspec.yaml",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Teks Hasil
            Text(
              'Nama: ${_wayangData!['nama']}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Asal: ${_wayangData!['asal']}',
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
            const Divider(height: 32),
            Text(
              _wayangData!['sejarah']!,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5, // Jarak antar baris
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
