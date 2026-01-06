import 'dart:io';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class PengenalanWayangPage extends StatefulWidget {
  const PengenalanWayangPage({super.key});

  @override
  State<PengenalanWayangPage> createState() => _PengenalanWayangPageState();
}

class _PengenalanWayangPageState extends State<PengenalanWayangPage>
    with SingleTickerProviderStateMixin {
  XFile? _image;
  bool _loading = false;
  Map<String, dynamic>? _result;

  // Controller untuk animasi hasil
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
        );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);

    if (picked != null) {
      setState(() {
        _image = picked;
        _result = null;
        _animController.reset();
      });
    }
  }

  Future<void> _predictWayang() async {
    if (_image == null) return;
    setState(() => _loading = true);

    // Reset animasi sebelum mulai
    _animController.reset();

    try {
      final response = await ApiService.predictWayang(_image!);

      setState(() {
        _result = response;
      });

      // Jalankan animasi muncul hasil
      if (response != null) {
        _animController.forward();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memproses: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Warna Tema Wayanusa
    final primaryColor = const Color(0xff4B3425); // Coklat Kayu Tua
    final accentColor = const Color(0xffD4AF37); // Emas
    final bgColor = const Color(0xffFDFBF7); // Putih Kertas Tua

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Wayanusa AI",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // HEADER TEXT
            Text(
              "Deteksi Karakter Wayang",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: primaryColor,
                fontFamily:
                    'Serif', // Menggunakan font bawaan serif agar klasik
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ambil foto wayang dan biarkan AI mengenalnya",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            // IMAGE CONTAINER
            _buildImagePreview(),

            const SizedBox(height: 30),

            // ACTION BUTTONS (KAMERA & GALERI)
            Row(
              children: [
                Expanded(
                  child: _buildOptionButton(
                    icon: Icons.camera_alt_outlined,
                    label: "Kamera",
                    color: primaryColor,
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildOptionButton(
                    icon: Icons.photo_library_outlined,
                    label: "Galeri",
                    color: Colors.brown[400]!,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // PREDICT BUTTON (CTA)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _image != null && !_loading
                  ? SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _predictWayang,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: accentColor.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 22),
                            SizedBox(width: 10),
                            Text(
                              "Analisis Wayang",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _loading
                  ? _buildLoadingState()
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 30),

            // RESULT CARD
            if (_result != null) _buildResultCard(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // WIDGET: Loading State yang Cantik
  Widget _buildLoadingState() {
    return Column(
      children: [
        const CircularProgressIndicator(color: Color(0xffD4AF37)),
        const SizedBox(height: 15),
        Text(
          "AI sedang membaca wayang...",
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // WIDGET: Tombol Pilihan (Kamera/Galeri)
  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // WIDGET: Image Preview Frame
  Widget _buildImagePreview() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(_image?.path),
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _image != null
              ? _buildImageWidget()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_search_rounded,
                      size: 80,
                      color: Colors.brown[100],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Preview Foto",
                      style: TextStyle(color: Colors.brown[200]),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Helper untuk menampilkan gambar (Web/Mobile)
  Widget _buildImageWidget() {
    if (kIsWeb) {
      return Image.network(_image!.path, fit: BoxFit.cover);
    } else {
      return Image.file(File(_image!.path), fit: BoxFit.cover);
    }
  }

  // WIDGET: Result Card (Modern & Clean)
  Widget _buildResultCard() {
    // Cek apakah hasilnya valid atau tidak
    bool isUnknown = _result!['prediksi'] == "Objek Tidak Dikenali";

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _animController,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isUnknown ? Colors.red[50] : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isUnknown
                  ? Colors.red.withOpacity(0.3)
                  : const Color(0xffD4AF37).withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label Hasil
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Teridentifikasi sebagai:",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _result!['prediksi'] ?? "Unknown",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          // Merah jika unknown, Coklat jika wayang
                          color: isUnknown
                              ? Colors.red[800]
                              : const Color(0xff4B3425),
                          fontFamily: 'Serif',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      _result!['confidence'] ?? "0%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30, thickness: 1),

              // Deskripsi
              const Text(
                "Deskripsi Karakter",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _result!['deskripsi'] ?? "Tidak ada deskripsi tersedia.",
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
