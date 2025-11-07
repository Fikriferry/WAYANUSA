import 'package:flutter/material.dart';
import 'chatbotpage.dart';

class HomeWayangPage extends StatelessWidget {
  const HomeWayangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F6F2),
      body: SafeArea(
        child: Stack(
          children: [

            // SEMUA ISI SCROLLING

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // LOGO + AVATAR

                  SizedBox(
                    height: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Image.asset(
                            "assets/logo.png",
                            height: 40,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: const AssetImage("assets/avatar.png"),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Center(
                    child: Text(
                      "Selamat Datang, Vikzz!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // BANNER
                  Container(
                    height: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      image: const DecorationImage(
                        image: AssetImage("assets/banner.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 4 MENU ICON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _menuItem("assets/icon_scan.png", "Pengenalan\nWayang"),
                      _menuItem("assets/icon_video.png", "Video"),
                      _menuItem("assets/icon_dalang.png", "Cari\nDalang"),
                      _menuItem("assets/icon_play.png", "Menjadi\nDalang"),
                    ],
                  ),

                  const SizedBox(height: 35),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Artikel Kisah Wayang Kulit",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Selengkapnya",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // AREA ARTIKEL
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 190,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 190,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Penjelasan Wayang Kulit",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // FLOATING CHAT BOT
           Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatBotPage()),
                  );
                },
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xffE8D4BE),
                  child: Image.asset(
                    "assets/icon_robot.png",
                    height: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // COMPONENT MENU ICON (SCAN, VIDEO, DLL)
  Widget _menuItem(String icon, String label) {
    return Column(
      children: [
        Image.asset(icon, height: 42),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            height: 1.1,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}