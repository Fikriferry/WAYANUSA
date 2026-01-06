import 'dart:async';
import 'package:flutter/material.dart';
import '../services/quiz_api.dart';
import '../services/api_service.dart';

class QuizQuestionPage extends StatefulWidget {
  final String level;

  const QuizQuestionPage({Key? key, required this.level}) : super(key: key);

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  // Palet Warna Wayanusa
  final Color primaryColor = const Color(0xFFD4A373);
  final Color secondaryColor = const Color(0xFF4B3425);
  final Color surfaceColor = const Color(0xFFF9F9F9);

  int currentQuestionIndex = 0;
  int selectedIndex = -1;
  int timeLeft = 30;
  int benar = 0;
  int salah = 0;
  Timer? timer;
  bool isLoading = true;
  List<Map<String, dynamic>> questions = [];
  String errorMessage = '';
  List<Map<String, dynamic>> userAnswers = [];

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      final levelId = _getLevelId(widget.level);
      final questionsData = await QuizApi.getQuestions(levelId);

      final transformedQuestions = (questionsData['questions'] as List<dynamic>)
          .map((q) {
            final correctAnswerLetter = q['correct_answer']
                .toString()
                .toLowerCase();
            int correctAnswerIndex;
            switch (correctAnswerLetter) {
              case 'a':
                correctAnswerIndex = 0;
                break;
              case 'b':
                correctAnswerIndex = 1;
                break;
              case 'c':
                correctAnswerIndex = 2;
                break;
              case 'd':
                correctAnswerIndex = 3;
                break;
              default:
                correctAnswerIndex = 0;
            }

            return {
              'id': q['id'],
              'question': q['question'],
              'options': [q['a'], q['b'], q['c'], q['d']],
              'answer': correctAnswerIndex,
            };
          })
          .toList();

      if (mounted) {
        setState(() {
          questions = transformedQuestions;
          isLoading = false;
        });
        startTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Gagal memuat: $e';
          isLoading = false;
        });
      }
    }
  }

  void startTimer() {
    timer?.cancel();
    setState(() => timeLeft = 30);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        t.cancel();
        salah++;
        showAnswerDialog(false, -1);
      }
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Keluar Kuis?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text("Progres Anda saat ini tidak akan disimpan."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Lanjut Main"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text(
                  "Keluar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void showAnswerDialog(bool isCorrect, int selectedAnswerIndex) {
    final correctAnswer =
        questions[currentQuestionIndex]["options"][questions[currentQuestionIndex]["answer"]];

    // Simpan jawaban user
    final userAnswerLetter = selectedAnswerIndex != -1
        ? String.fromCharCode(97 + selectedAnswerIndex)
        : "";

    userAnswers.add({
      'question_id':
          questions[currentQuestionIndex]['id'] ?? currentQuestionIndex + 1,
      'user_answer': userAnswerLetter,
      'is_correct': isCorrect,
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Animasi
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect ? Icons.check_rounded : Icons.close_rounded,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 50,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                isCorrect ? "Jawaban Benar!" : "Yah, Salah!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isCorrect ? Colors.green[700] : Colors.red[700],
                ),
              ),
              const SizedBox(height: 10),
              if (!isCorrect) ...[
                const Text(
                  "Jawaban yang benar adalah:",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  correctAnswer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    goToNextQuestion();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Lanjut",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showFinalScore() async {
    int nilai = (benar / questions.length * 100).round();

    // Submit ke backend
    try {
      final profile = await ApiService.getProfile();
      if (profile != null) {
        await QuizApi.submitQuiz(
          userId: profile['id'],
          levelId: _getLevelId(widget.level),
          score: nilai,
          totalQuestions: questions.length,
          userAnswers: userAnswers,
        );
      }
    } catch (e) {
      debugPrint("Gagal submit skor: $e");
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/icon_quiz.png",
                height: 80,
              ), // Pastikan icon ini ada atau ganti Icon
              const SizedBox(height: 20),
              const Text(
                "Kuis Selesai!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _scoreBadge(Icons.check_circle, Colors.green, "$benar"),
                  const SizedBox(width: 20),
                  _scoreBadge(Icons.cancel, Colors.red, "$salah"),
                ],
              ),
              const SizedBox(height: 20),
              Text("Total Skor", style: TextStyle(color: Colors.grey[600])),
              Text(
                "$nilai",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup Dialog
                    Navigator.pop(context, true); // Kembali ke Menu Kuis
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Selesai",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreBadge(IconData icon, Color color, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 5),
          Text(
            val,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  int _getLevelId(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 1;
      case 'intermediate':
        return 2;
      case 'advanced':
        return 3;
      case 'expert':
        return 4;
      default:
        return 1;
    }
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedIndex = -1;
      });
      startTimer();
    } else {
      timer?.cancel();
      showFinalScore();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ===================== UI BUILDER =====================

  @override
  Widget build(BuildContext context) {
    // Hitung progress (0.0 s/d 1.0)
    double progress = questions.isNotEmpty
        ? (currentQuestionIndex + 1) / questions.length
        : 0.0;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: surfaceColor,
        body: SafeArea(
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : errorMessage.isNotEmpty
              ? _buildErrorState()
              : questions.isEmpty
              ? const Center(child: Text("Soal belum tersedia"))
              : Column(
                  children: [
                    // 1. HEADER (Back & Progress)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.grey,
                            onPressed: () async {
                              // 1. Panggil dialog konfirmasi
                              final shouldPop = await _onWillPop();

                              // 2. Jika user pilih "Keluar" (true), tutup halaman ini secara manual
                              if (shouldPop == true && context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[300],
                                color: primaryColor,
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${currentQuestionIndex + 1}/${questions.length}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // 2. TIMER BADGE
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: timeLeft <= 10
                                    ? Colors.redAccent
                                    : secondaryColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (timeLeft <= 10
                                                ? Colors.red
                                                : secondaryColor)
                                            .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "$timeLeft detik",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // 3. QUESTION CARD
                            Text(
                              questions[currentQuestionIndex]["question"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: secondaryColor,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // 4. OPTIONS LIST
                            ...List.generate(
                              questions[currentQuestionIndex]["options"].length,
                              (index) => _buildOptionCard(index),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 5. SUBMIT BUTTON
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Color(0xFFEEEEEE)),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: selectedIndex == -1
                              ? null // Disable jika belum pilih
                              : () {
                                  timer?.cancel();
                                  final correctIndex =
                                      questions[currentQuestionIndex]["answer"]
                                          as int;
                                  bool isCorrect =
                                      selectedIndex == correctIndex;
                                  if (isCorrect)
                                    benar++;
                                  else
                                    salah++;
                                  showAnswerDialog(isCorrect, selectedIndex);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Kirim Jawaban",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(int index) {
    final bool isSelected = selectedIndex == index;
    final String optionText = questions[currentQuestionIndex]["options"][index];
    // Huruf A, B, C, D
    final String optionLetter = String.fromCharCode(65 + index);

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Lingkaran Huruf (A/B/C/D)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  optionLetter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Teks Jawaban
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  color: isSelected ? secondaryColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
            // Radio Icon di Kanan
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: primaryColor, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(errorMessage, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = '';
              });
              loadQuestions();
            },
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }
}
