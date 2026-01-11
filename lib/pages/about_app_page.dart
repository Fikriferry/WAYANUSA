import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Palet Warna
    const primaryColor = Color(0xFFD4A373);
    const secondaryColor = Color(0xFF4B3425);
    const bgColor = Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Tentang Aplikasi",
          style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // 1. LOGO & VERSI
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    // Ganti asset ini dengan logo aplikasimu
                    child: Image.asset(
                      "assets/logo.png", 
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "WAYANUSA",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: secondaryColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Versi 1.0.0 (Beta)",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 2. DESKRIPSI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Wayanusa adalah platform digital yang menggabungkan kecerdasan buatan (AI) dengan kearifan lokal untuk melestarikan budaya Wayang Indonesia. Kenali karakter wayang hanya dengan satu jepretan foto.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 3. FITUR UTAMA (Cards)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "FITUR UTAMA",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            _buildFeatureTile(
              icon: Icons.camera_alt_outlined,
              title: "Smart Wayang",
              desc: "Tanya jawab dengan Cepot AI seputar sejarah & filosofi wayang layaknya teman ngobrol.",
            ),
            _buildFeatureTile(
              icon: Icons.camera_alt_outlined,
              title: "Smart Detection",
              desc: "Deteksi nama & karakter wayang menggunakan AI.",
            ),
            _buildFeatureTile(
              icon: Icons.chat_bubble_outline,
              title: "Chatbot Cepot",
              desc: "Tanya jawab seputar sejarah & filosofi wayang.",
            ),
            _buildFeatureTile(
              icon: Icons.map_outlined,
              title: "Cari Dalang",
              desc: "Temukan seniman dalang terdekat di kotamu.",
            ),

            const SizedBox(height: 40),

            // 4. CREDIT / DEVELOPER TEAM
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              color: Colors.white,
              child: Column(
                children: [
                  const Text(
                    "Dikembangkan oleh",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Wayanusa Dev",
                    style: TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(Icons.code),
                      const SizedBox(width: 20),
                      _buildSocialIcon(Icons.public),
                      const SizedBox(width: 20),
                      _buildSocialIcon(Icons.email),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "© 2024 Wayanusa. All Rights Reserved.",
                    style: TextStyle(color: Colors.grey[400], fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET HELPERS

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A373).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFD4A373), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF4B3425),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Icon(icon, size: 20, color: Colors.grey[600]),
    );
  }
}