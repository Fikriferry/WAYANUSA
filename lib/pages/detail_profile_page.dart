import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk fitur Copy to Clipboard
import '../services/api_service.dart';

class DetailProfilePage extends StatefulWidget {
  const DetailProfilePage({super.key});

  @override
  State<DetailProfilePage> createState() => _DetailProfilePageState();
}

class _DetailProfilePageState extends State<DetailProfilePage> {
  bool _isLoading = true;
  
  // Variabel untuk menampung data
  String _id = "-";
  String _name = "-";
  String _email = "-";

  // Palet Warna
  final Color primaryColor = const Color(0xFFD4A373);
  final Color secondaryColor = const Color(0xFF4B3425);
  final Color bgColor = const Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ApiService.getProfile();
      if (mounted && data != null) {
        setState(() {
          _id = data['id'].toString();
          _name = data['name'] ?? 'Tanpa Nama';
          _email = data['email'] ?? 'Tidak ada email';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi Copy Text (Fitur tambahan agar interaktif)
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$label berhasil disalin!"),
        duration: const Duration(seconds: 1),
        backgroundColor: secondaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Detail Profil",
          style: TextStyle(color: Color(0xFF4B3425), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4B3425)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // 1. AVATAR DISPLAY (Read Only)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage("https://cdn-icons-png.flaticon.com/512/3135/3135715.png"),
                      backgroundColor: Color(0xFFFFF3E0),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Nama Besar di bawah foto
                  Text(
                    _name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B3425),
                    ),
                  ),
                  Text(
                    "Anggota Wayanusa",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 2. INFO CARDS
                  _buildSectionLabel("Informasi Akun"),
                  
                  _buildInfoTile(
                    label: "ID Pengguna",
                    value: _id,
                    icon: Icons.fingerprint,
                    enableCopy: true,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoTile(
                    label: "Nama Lengkap",
                    value: _name,
                    icon: Icons.person_outline,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoTile(
                    label: "Alamat Email",
                    value: _email,
                    icon: Icons.email_outlined,
                    enableCopy: true,
                  ),

                  // Tambahan info visual (opsional)
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: secondaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Data ini dikelola oleh sistem Wayanusa dan hanya dapat diubah melalui Admin.",
                            style: TextStyle(color: secondaryColor, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
    bool enableCopy = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A373).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFD4A373), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF4B3425),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (enableCopy)
            IconButton(
              onPressed: () => _copyToClipboard(value, label),
              icon: Icon(Icons.copy_rounded, color: Colors.grey[400], size: 18),
              tooltip: "Salin $label",
            ),
        ],
      ),
    );
  }
}