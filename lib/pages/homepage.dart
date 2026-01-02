import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeWayangPage extends StatefulWidget {
  const HomeWayangPage({super.key});

  @override
  State<HomeWayangPage> createState() => _HomeWayangPageState();
}

class _HomeWayangPageState extends State<HomeWayangPage> {
  String namaUser = "Loading...";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  // ================= LOAD USER =================
  void loadUser() async {
    final profile = await ApiService.getProfile();

    if (profile != null) {
      setState(() {
        namaUser = profile['name'];
      });
    } else {
      setState(() {
        namaUser = "Pengguna";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFEFBF5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              SizedBox(
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/logo.png",
                        height: 31,
                      ),
                    ),

                    // 👤 AVATAR → PROFILE
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                        child: const CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage("assets/profil.png"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ===== WELCOME TEXT =====
              Center(
                child: Text(
                  "Selamat Datang, $namaUser",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff4B3425),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ===== BANNER =====
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  "assets/banner.jpg",
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 30),

              // ===== MENU =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _menuItem(context, "assets/icon_scan.png", "Pengenalan\nWayang"),
                  _menuItem(context, "assets/icon_quiz.png", "Tes\nSingkat"),
                  _menuItem(context, "assets/icon_dalang.png", "Mencari\nDalang"),
                  _menuItem(context, "assets/icon_video.png", "Pertunjukan\nWayang"),
                  _menuItem(context, "assets/icon_play.png", "Menjadi\nDalang"),
                ],
              ),

              const SizedBox(height: 70),
            ],
          ),
        ),
      ),

      // ===== CHATBOT =====
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffE8D4BE),
        onPressed: () {
          Navigator.pushNamed(context, '/chatbot');
        },
        child: Image.asset(
          "assets/icon_robot.png",
          height: 30,
        ),
      ),
    );
  }

  // ===== MENU ITEM =====
  Widget _menuItem(BuildContext context, String icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == "Pengenalan\nWayang") {
          Navigator.pushNamed(context, '/pengenalan_wayang');
        } else if (label == "Tes\nSingkat") {
          Navigator.pushNamed(context, '/tes_singkat');
        } else if (label == "Mencari\nDalang") {
          Navigator.pushNamed(context, '/cari_dalang');
        } else if (label == "Pertunjukan\nWayang") {
          Navigator.pushNamed(context, '/video');
        } else if (label == "Menjadi\nDalang") {
          Navigator.pushNamed(context, '/simulasi_dalang');
        }
      },
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0xffF3E7D3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Image.asset(icon, height: 30),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xff4B3425),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
