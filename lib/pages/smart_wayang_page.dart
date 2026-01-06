import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SmartWayangPage extends StatelessWidget {
  const SmartWayangPage({super.key});

  // Ganti URL ini dengan alamat website Flask kamu yang bisa diakses
  // Jika deploy, pakai domain asli. Jika lokal, pastikan HP & Laptop satu WiFi.
  final String _websiteUrl = 'http://192.168.1.17:8000/smart-wayang';

  Future<void> _launchURL(BuildContext context) async {
    final Uri url = Uri.parse(_websiteUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $_websiteUrl');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal membuka website: $e")),
        );
      }
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
      extendBodyBehindAppBar: true, // Agar gambar tembus ke atas
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 10, top: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: secondaryColor, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HERO IMAGE (Robot Cepot)
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      // Ganti dengan gambar Robot Cepot kamu yang keren
                      image: NetworkImage('assets/cepot.png'), 
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                // Gradient Overlay
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                // Teks Judul
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "PROJECT EXPERIMENTAL",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Smart Wayang\nAnimatronic",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                          fontFamily: 'Serif',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Gabungan Seni Tradisi & IoT",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 2. PENJELASAN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Apa itu Smart Wayang?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Smart Wayang adalah sistem animatronik di mana wayang golek fisik dapat bergerak dan berbicara secara real-time menggunakan kecerdasan buatan (AI).",
                    style: TextStyle(color: Colors.grey[600], height: 1.6),
                  ),
                  
                  const SizedBox(height: 30),

                  // Fitur Cards
                  Row(
                    children: [
                      Expanded(child: _buildFeatureCard(Icons.mic, "Voice\nControl")),
                      const SizedBox(width: 15),
                      Expanded(child: _buildFeatureCard(Icons.psychology, "AI\nThinking")),
                      const SizedBox(width: 15),
                      Expanded(child: _buildFeatureCard(Icons.settings_input_component, "Servo\nMotor")),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // 3. NOTICE SECTION (Kenapa harus di Web?)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0), // Krem oranye
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.laptop_chromebook_rounded, size: 40, color: secondaryColor),
                        const SizedBox(height: 15),
                        const Text(
                          "Akses Eksklusif via Desktop",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Fitur ini memerlukan koneksi kabel USB ke Arduino untuk menggerakkan motor servo. Silakan buka website Wayanusa melalui Laptop/PC Anda.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Spasi bawah
                ],
              ),
            ),
          ],
        ),
      ),

      // 4. FLOATING BUTTON BAWAH
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () => _launchURL(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Buka Website Sekarang",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.open_in_new_rounded, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget: Feature Card
  Widget _buildFeatureCard(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFD4A373), size: 28),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF4B3425),
            ),
          ),
        ],
      ),
    );
  }
}