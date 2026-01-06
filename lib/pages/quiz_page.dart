import 'package:flutter/material.dart';
import 'quiz_question_page.dart';
import 'leaderboard_page.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data Level Kuis
    final quizLevels = [
      {
        "level": "Beginner",
        "title": "Kenalan Tokoh",
        "desc": "Tebak nama tokoh wayang populer.",
        "color1": const Color(0xFF81C784), // Hijau Muda
        "color2": const Color(0xFF2E7D32), // Hijau Tua
        "image": "assets/wayang.png", // Pastikan aset ini ada
        "locked": false,
      },
      {
        "level": "Intermediate",
        "title": "Kisah & Perang",
        "desc": "Sejarah Baratayuda & Ramayana.",
        "color1": const Color(0xFFFFD54F), // Kuning
        "color2": const Color(0xFFF57F17), // Oranye
        "image": "assets/wayang.png",
        "locked": false,
      },
      {
        "level": "Advanced",
        "title": "Filosofi Ksatria",
        "desc": "Menelusuri watak & ajaran moral.",
        "color1": const Color(0xFFE57373), // Merah Muda
        "color2": const Color(0xFFC62828), // Merah Tua
        "image": "assets/wayang.png",
        "locked": false,
      },
      {
        "level": "Expert",
        "title": "Dalang Sejati",
        "desc": "Detail senjata, silsilah, & mantra.",
        "color1": const Color(0xFF64B5F6), // Biru Muda
        "color2": const Color(0xFF1565C0), // Biru Tua
        "image": "assets/wayang.png",
        "locked": false,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. CUSTOM APP BAR
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFF9F9F9),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4B3425), size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 20),
                        SizedBox(width: 5),
                        Text(
                          "Peringkat",
                          style: TextStyle(
                            color: Color(0xFF4B3425),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: const Text(
                "Zona Kuis",
                style: TextStyle(
                  color: Color(0xFF4B3425),
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  fontFamily: 'Serif',
                ),
              ),
            ),
          ),

          // 2. LIST LEVEL
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final quiz = quizLevels[index];
                  return QuizLevelCard(
                    index: index + 1,
                    level: quiz['level'] as String,
                    title: quiz['title'] as String,
                    desc: quiz['desc'] as String,
                    color1: quiz['color1'] as Color,
                    color2: quiz['color2'] as Color,
                    imagePath: quiz['image'] as String,
                    isLocked: quiz['locked'] as bool,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizQuestionPage(level: quiz['level'] as String),
                        ),
                      );

                      if (result == true && context.mounted) {
                        _showSuccessDialog(context);
                      }
                    },
                  );
                },
                childCount: quizLevels.length,
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, color: Colors.amber, size: 60),
            const SizedBox(height: 10),
            const Text(
              "Hebat!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Skor kamu sudah disimpan.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Tutup dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B3425),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Lihat Peringkat"),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizLevelCard extends StatelessWidget {
  final int index;
  final String level;
  final String title;
  final String desc;
  final Color color1;
  final Color color2;
  final String imagePath;
  final bool isLocked;
  final VoidCallback onTap;

  const QuizLevelCard({
    super.key,
    required this.index,
    required this.level,
    required this.title,
    required this.desc,
    required this.color1,
    required this.color2,
    required this.imagePath,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140, // Tinggi kartu fixed agar rapi
      margin: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: isLocked ? null : onTap,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // 1. BACKGROUND CARD (Gradient)
            Container(
              height: 120, // Sedikit lebih pendek dari container utama agar gambar bisa pop-out
              margin: const EdgeInsets.only(top: 10), // Turun sedikit
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLocked 
                      ? [Colors.grey.shade400, Colors.grey.shade600] 
                      : [color1, color2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color2.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),

            // 2. PATTERN DEKORASI (Lingkaran transparan)
            Positioned(
              right: -20,
              top: 30,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),

            // 3. KONTEN TEKS
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 120, 10), // Kanan dikosongkan untuk gambar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge Level
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "LEVEL $index • $level",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Judul
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Deskripsi
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 4. GAMBAR POP-OUT (Kanan)
            Positioned(
              right: 10,
              bottom: 10,
              child: isLocked 
                  ? Icon(Icons.lock_rounded, size: 80, color: Colors.white.withOpacity(0.3))
                  : Hero(
                      tag: "quiz_img_$index",
                      child: Image.asset(
                        imagePath,
                        height: 130, // Lebih tinggi dari background card
                        fit: BoxFit.contain,
                      ),
                    ),
            ),

            // 5. TOMBOL PLAY (Floating)
            Positioned(
              right: 110, // Di tengah antara teks dan gambar
              bottom: 25,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)
                  ],
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: isLocked ? Colors.grey : color2,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}