import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PengenalanPage extends StatefulWidget {
  const PengenalanPage({super.key});

  @override
  State<PengenalanPage> createState() => _PengenalanPageState();
}

class _PengenalanPageState extends State<PengenalanPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  File? _image;
  bool isLoading = false;

  Map<String, dynamic>? result;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final String baseUrl = "http://10.0.2.2:8000/api/predict-wayang";

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ================= IMAGE PICK =================
  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        result = null;
      });
      predictWayang();
    }
  }

  // ================= API CALL =================
  Future<void> predictWayang() async {
    if (_image == null) return;

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final request = http.MultipartRequest("POST", Uri.parse(baseUrl));
    request.files.add(await http.MultipartFile.fromPath("image", _image!.path));

    if (token != null) {
      request.headers["Authorization"] = "Bearer $token";
    }

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      setState(() {
        result = jsonDecode(respStr);
        isLoading = false;
      });
      _animController.forward(from: 0);
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memprediksi wayang")),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Pengenalan Wayang AI"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildAction(),
            const SizedBox(height: 20),
            if (_image != null) _buildPreview(),
            if (isLoading) _buildLoading(),
            if (result != null) _buildResult(),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB6783D), Color(0xFFD9A441)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kenali Wayangmu",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Ambil foto atau unggah gambar wayang untuk diprediksi oleh AI.",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ================= ACTION =================
  Widget _buildAction() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.camera_alt,
            label: "Kamera",
            onTap: () => pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _actionButton(
            icon: Icons.image,
            label: "Upload",
            onTap: () => pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: const Color(0xFFB6783D)),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ================= PREVIEW =================
  Widget _buildPreview() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(_image!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  // ================= LOADING =================
  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: CircularProgressIndicator(),
    );
  }

  // ================= RESULT =================
  Widget _buildResult() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hasil Prediksi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              result!['prediksi'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB6783D),
              ),
            ),
            const SizedBox(height: 6),
            Text("Akurasi: ${result!['confidence']}"),
            const Divider(height: 30),
            Text(
              result!['deskripsi'],
              style: const TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
