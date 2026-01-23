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

  late AnimationController _animController;
  late Animation<Offset> _slideAnim;

  // Warna Tema
  final primaryColor = const Color(0xff4B3425); // Coklat Kayu Tua
  final accentColor = const Color(0xffD4AF37); // Emas
  final bgColor = const Color(0xffFDFBF7); // Putih Kertas Tua
  final secondaryColor = const Color(0xff8D6E63); // Coklat Muda

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
    _animController.reset();

    try {
      final response = await ApiService.predictWayang(_image!);
      setState(() {
        _result = response;
      });
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
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        // 1. TAMBAHAN: Tombol Kembali Custom
        leading: Container(
          margin: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
            onPressed: () => Navigator.pop(context), // Aksi kembali
            tooltip: "Kembali",
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(
                0.5,
              ), // Latar transparan
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        title: Text(
          "Wayanusa AI",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontFamily: 'Serif',
            color: primaryColor,
          ),
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
            _buildHeader(),
            const SizedBox(height: 30),
            _buildImagePreview(),
            const SizedBox(height: 30),
            _buildActionButtons(),
            const SizedBox(height: 25),
            _buildPredictButton(),
            const SizedBox(height: 30),
            if (_result != null) _buildResultCard(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "Deteksi Karakter Wayang",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: primaryColor,
            fontFamily: 'Serif',
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Unggah foto wayang kulit untuk mengenali tokoh dan filosofinya.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Center(
        // 1. Tengahkan widget agar rapi
        child: Container(
          key: ValueKey(_image?.path),
          // 2. Atur ukuran FIX agar Portrait & tidak terlalu besar
          width: 260, // Lebar dibatasi (lebih ramping)
          height: 360, // Tinggi disesuaikan (rasio portrait ~3:4)
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _image != null
                ? _buildImageWidget()
                : Container(
                    color: const Color(0xffF5F0EB), // Warna placeholder soft
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.portrait_rounded, // Icon ganti portrait
                          size: 50,
                          color: secondaryColor.withOpacity(0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Preview Foto",
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "",
                          style: TextStyle(
                            color: secondaryColor.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (kIsWeb) {
      return Image.network(_image!.path, fit: BoxFit.cover);
    } else {
      return Image.file(File(_image!.path), fit: BoxFit.cover);
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildOptionButton(
            icon: Icons.camera_alt_rounded,
            label: "Kamera",
            color: primaryColor,
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOptionButton(
            icon: Icons.image_rounded,
            label: "Galeri",
            color: secondaryColor,
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            borderRadius: BorderRadius.circular(16),
            color: color.withOpacity(0.05),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _loading
          ? _buildLoadingState()
          : _image != null
          ? SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _predictWayang,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: accentColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 22),
                    SizedBox(width: 12),
                    Text(
                      "Analisis Wayang",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: accentColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "AI sedang menganalisis...",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    bool isUnknown = _result!['prediksi'] == "Objek Tidak Dikenali";

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _animController,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isUnknown
                  ? Colors.red.withOpacity(0.2)
                  : accentColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hasil Deteksi",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _result!['prediksi'] ?? "Unknown",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: isUnknown ? Colors.red[700] : primaryColor,
                            fontFamily: 'Serif',
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isUnknown)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _result!['confidence'] ?? "0%",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(height: 1, thickness: 1),
              ),
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Tentang Karakter",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _result!['deskripsi'] ?? "Tidak ada deskripsi tersedia.",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey[800],
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
