import 'package:flutter/material.dart';
import 'quiz_question_page.dart'; // import halaman kedua
import 'leaderboard_page.dart'; // import leaderboard page

class QuizPage extends StatelessWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quizLevels = [
      {
        "level": "Beginner",
        "title": "Pengenalan Tokoh Wayang",
        "quote": "Dari nama-nama, lahir kisah yang abadi.",
        "color": const Color(0xFFFFCC80),
        "image": "assets/wayang.png",
      },
      {
        "level": "Intermediate",
        "title": "Kisah dan Pertempuran",
        "quote": "Dalam perang, kebenaran adalah senjata terkuat.",
        "color": const Color(0xFFFF8A65),
        "image": "assets/wayang.png",
      },
      {
        "level": "Advanced",
        "title": "Kebijaksanaan Para Ksatria",
        "quote": "Pemimpin sejati menundukkan diri sebelum menaklukkan dunia.",
        "color": const Color(0xFFE57373),
        "image": "assets/wayang.png",
      },
      {
        "level": "Expert",
        "title": "Makna di Balik Bayangan",
        "quote": "Bayangan di balik layar adalah cermin jiwa manusia.",
        "color": const Color(0xFF64B5F6),
        "image": "assets/wayang.png",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quiz',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard, color: Colors.brown),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaderboardPage()),
              );
            },
            tooltip: 'Leaderboard',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: quizLevels.length,
        itemBuilder: (context, index) {
          final quiz = quizLevels[index];
          return QuizCard(
            level: quiz['level'] as String,
            title: quiz['title'] as String,
            quote: quiz['quote'] as String,
            color: quiz['color'] as Color,
            imagePath: quiz['image'] as String,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      QuizQuestionPage(level: quiz['level'] as String),
                ),
              );

              // If quiz was completed, show success message and navigate to leaderboard
              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '🎉 Quiz selesai! Skor Anda telah disimpan di leaderboard',
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );

                // Navigate to leaderboard to show updated scores
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class QuizCard extends StatelessWidget {
  final String level;
  final String title;
  final String quote;
  final String imagePath;
  final Color color;
  final VoidCallback onPressed;

  const QuizCard({
    Key? key,
    required this.level,
    required this.title,
    required this.quote,
    required this.imagePath,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          // Text section
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"$title"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"$quote"',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: onPressed,
                      child: const Text(
                        "Mulai Quiz",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image section
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Image.asset(imagePath, height: 100, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
