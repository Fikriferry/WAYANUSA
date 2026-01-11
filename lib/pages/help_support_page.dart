import 'package:flutter/material.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  // Palet Warna
  final Color primaryColor = const Color(0xFFD4A373);
  final Color secondaryColor = const Color(0xFF4B3425);
  final Color bgColor = const Color(0xFFF9F9F9);

  // Controller untuk Form Masukan
  final TextEditingController _feedbackController = TextEditingController();

  // Data Dummy FAQ
  final List<Map<String, String>> _faqs = [
    {
      "question": "Bagaimana cara memindai Wayang?",
      "answer": "Buka menu 'Kamera' di halaman utama atau tekan tombol 'Analisis Wayang'. Arahkan kamera ke wayang golek secara tegak lurus dan pastikan pencahayaan cukup."
    },
    {
      "question": "Apakah aplikasi ini berbayar?",
      "answer": "Aplikasi Wayanusa dapat diunduh dan digunakan secara gratis. Namun, beberapa fitur premium mungkin akan hadir di masa mendatang."
    },
    {
      "question": "Bagaimana cara menghubungi Cepot?",
      "answer": "Cepot adalah asisten AI kami. Anda dapat mengaksesnya melalui menu Chatbot di halaman utama atau tombol melayang di pojok kanan bawah."
    },
    {
      "question": "Aplikasi sering menutup sendiri (Force Close)?",
      "answer": "Pastikan koneksi internet stabil dan Anda menggunakan versi terbaru. Jika masalah berlanjut, silakan hubungi tim teknis kami melalui Email."
    },
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // Fungsi Kirim Masukan (Simulasi)
  void _sendFeedback() {
    if (_feedbackController.text.trim().isEmpty) return;

    // Tutup keyboard
    FocusScope.of(context).unfocus();
    _feedbackController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text("Terima kasih atas masukan Anda!"),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Fungsi Hubungi (Simulasi URL Launcher)
  void _contactSupport(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Membuka $platform..."),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
    // Di sini nanti bisa pasang logic url_launcher (buka WA/Email app)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Pusat Bantuan",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER TEXT
            const Text(
              "Halo, ada yang bisa kami bantu?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B3425),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Pilih layanan bantuan di bawah ini atau baca pertanyaan umum.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),

            const SizedBox(height: 24),

            // 2. CONTACT CHANNELS (GRID)
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.chat_bubble_outline,
                    label: "WhatsApp",
                    color: Colors.green,
                    onTap: () => _contactSupport("WhatsApp Admin"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.email_outlined,
                    label: "Email",
                    color: Colors.orange,
                    onTap: () => _contactSupport("Aplikasi Email"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 3. FAQ SECTION
            _buildSectionHeader("Pertanyaan Umum (FAQ)"),
            const SizedBox(height: 10),
            
            ListView.builder(
              shrinkWrap: true, // Agar bisa masuk dalam SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                return _buildFaqTile(_faqs[index]);
              },
            ),

            const SizedBox(height: 30),

            // 4. FEEDBACK FORM
            _buildSectionHeader("Kirim Masukan"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  TextField(
                    controller: _feedbackController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Tulis kritik, saran, atau kendala Anda di sini...",
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                      filled: true,
                      fillColor: bgColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _sendFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Kirim Pesan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[500],
        letterSpacing: 1.2,
      ),
    );
  }

  // Kartu Kontak (WA/Email)
  Widget _buildContactCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Respon Cepat",
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // Item FAQ (Accordion)
  Widget _buildFaqTile(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            item['question']!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B3425),
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: primaryColor,
          children: [
            Text(
              item['answer']!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}