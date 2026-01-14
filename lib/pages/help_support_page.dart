import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  // ================= WARNA =================
  final Color primaryColor = const Color(0xFFD4A373);
  final Color secondaryColor = const Color(0xFF4B3425);
  final Color bgColor = const Color(0xFFF9F9F9);

  // ================= STATE =================
  final TextEditingController _feedbackController = TextEditingController();
  int _rating = 0;

  // ================= FAQ =================
  final List<Map<String, String>> _faqs = [
    {
      "question": "Bagaimana cara memindai Wayang?",
      "answer":
          "Buka menu Kamera di halaman utama atau tekan tombol Analisis Wayang."
    },
    {
      "question": "Apakah aplikasi ini berbayar?",
      "answer":
          "Aplikasi Wayanusa gratis digunakan. Fitur premium akan hadir."
    },
    {
      "question": "Bagaimana cara menghubungi Cepot?",
      "answer":
          "Cepot adalah asisten AI kami. Bisa diakses dari menu Chatbot."
    },
    {
      "question": "Aplikasi sering force close?",
      "answer":
          "Pastikan koneksi internet stabil dan aplikasi versi terbaru."
    },
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // ================= KIRIM ULASAN =================
  Future<void> _sendFeedback() async {
    if (_feedbackController.text.trim().isEmpty || _rating == 0) return;

    final success = await ApiService.postUlasan(
      rating: _rating,
      komentar: _feedbackController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Ulasan berhasil dikirim 🙏"
              : "Gagal mengirim ulasan 😢",
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      _feedbackController.clear();
      setState(() => _rating = 0);
    }
  }

  // ================= STAR RATING =================
  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            Icons.star,
            size: 32,
            color: index < _rating ? Colors.amber : Colors.grey[300],
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1;
            });
          },
        );
      }),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Pusat Bantuan",
          style: TextStyle(
            color: Color(0xFF4B3425),
            fontWeight: FontWeight.bold,
          ),
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
              "Pilih layanan bantuan atau kirim ulasan.",
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 30),

            // ================= FAQ =================
            _buildSectionHeader("Pertanyaan Umum"),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                return _buildFaqTile(_faqs[index]);
              },
            ),

            const SizedBox(height: 30),

            // ================= ULASAN =================
            _buildSectionHeader("Kirim Ulasan"),
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
                  _buildStarRating(),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Tulis ulasan kamu...",
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
                      onPressed: _rating == 0 ? null : _sendFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Kirim Ulasan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

  // ================= HELPER =================
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

  Widget _buildFaqTile(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        title: Text(
          item['question']!,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B3425),
          ),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Text(
            item['answer']!,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
