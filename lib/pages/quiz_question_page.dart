import 'dart:async';
import 'package:flutter/material.dart';
import 'leaderboard_page.dart';
import '../services/quiz_api.dart';
import '../services/api_service.dart';

class QuizQuestionPage extends StatefulWidget {
  final String level;

  const QuizQuestionPage({Key? key, required this.level}) : super(key: key);

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  int currentQuestionIndex = 0;
  int selectedIndex = -1;
  int timeLeft = 30;
  int benar = 0;
  int salah = 0;
  Timer? timer;
  bool isLoading = true;
  List<Map<String, dynamic>> questions = [];
  String errorMessage = '';
  List<Map<String, dynamic>> userAnswers =
      []; // Track user answers for submission

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      final levelId = _getLevelId(widget.level);
      final questionsData = await QuizApi.getQuestions(levelId);

      // Transform the data to match our expected format
      final transformedQuestions = (questionsData['questions'] as List<dynamic>)
          .map((q) {
            // Convert correct_answer from letter (a,b,c,d) to index (0,1,2,3)
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

      setState(() {
        questions = transformedQuestions;
        isLoading = false;
      });

      // Start timer after questions are loaded
      startTimer();
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat pertanyaan: $e';
        isLoading = false;
      });
      print('Error loading questions: $e');
    }
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = 30;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
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
    bool? exit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin keluar / berhenti kuis?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Tidak"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Ya"),
          ),
        ],
      ),
    );
    return exit ?? false;
  }

  void showAnswerDialog(bool isCorrect, int selectedAnswerIndex) {
    final correctAnswer =
        questions[currentQuestionIndex]["options"][questions[currentQuestionIndex]["answer"]];
    final selectedAnswer = selectedAnswerIndex != -1
        ? questions[currentQuestionIndex]["options"][selectedAnswerIndex]
        : "Tidak menjawab";

    // Record user answer for submission
    final userAnswerLetter = selectedAnswerIndex != -1
        ? String.fromCharCode(
            97 + selectedAnswerIndex,
          ) // Convert index to letter (0=a, 1=b, etc.)
        : "";

    userAnswers.add({
      'question_id':
          questions[currentQuestionIndex]['id'] ?? currentQuestionIndex + 1,
      'user_answer': userAnswerLetter,
      'is_correct': isCorrect,
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isCorrect ? "Benar!" : "Salah!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCorrect ? Colors.green : Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isCorrect
                  ? "Jawaban benar: $correctAnswer"
                  : "Jawaban kamu: $selectedAnswer\nJawaban benar: $correctAnswer",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              goToNextQuestion();
            },
            child: const Text("Lanjut"),
          ),
        ],
      ),
    );
  }

  void showFinalScore() async {
    int nilai = (benar / questions.length * 100).round();

    // Submit score to backend
    try {
      final profile = await ApiService.getProfile();
      if (profile != null) {
        final userId = profile['id'];
        final levelId = _getLevelId(widget.level);

        print("Submitting quiz for user $userId, level $levelId, score $nilai");
        print("User answers: $userAnswers");

        final result = await QuizApi.submitQuiz(
          userId: userId,
          levelId: levelId,
          score: nilai,
          totalQuestions: questions.length,
          userAnswers: userAnswers,
        );

        print("Quiz submission result: $result");
      } else {
        print("Profile is null, cannot submit quiz");
      }
    } catch (e) {
      print("Error submitting quiz: $e");
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Kuis Selesai!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Benar: $benar"),
            Text("Salah: $salah"),
            const SizedBox(height: 10),
            Text(
              "Nilai Kamu: $nilai",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.brown,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(
                context,
                true,
              ); // Return true to indicate quiz completed
            },
            child: const Text("Tutup"),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.brown.shade50,
        appBar: AppBar(
          backgroundColor: Colors.brown.shade700,
          title: Text(widget.level),
          centerTitle: true,
          elevation: 4,
        ),
        body: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Memuat pertanyaan...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : errorMessage.isNotEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = '';
                          });
                          loadQuestions();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Coba Lagi',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : questions.isEmpty
            ? const Center(
                child: Text(
                  'Tidak ada pertanyaan tersedia untuk level ini',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${currentQuestionIndex + 1}/${questions.length}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade200,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "⏳ Waktu: $timeLeft detik",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      shadowColor: Colors.brown.shade200,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          questions[currentQuestionIndex]["question"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(
                      questions[currentQuestionIndex]["options"].length,
                      (index) {
                        final isSelected = selectedIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => selectedIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            height: 60, // ✨ fixed height untuk semua opsi
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.brown.shade400
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.brown
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 6,
                                  offset: const Offset(2, 2),
                                  color: Colors.black.withOpacity(0.05),
                                ),
                              ],
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                questions[currentQuestionIndex]["options"][index],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade700,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                      ),
                      onPressed: selectedIndex == -1
                          ? null
                          : () {
                              final correctIndex =
                                  questions[currentQuestionIndex]["answer"]
                                      as int;
                              bool isCorrect = selectedIndex == correctIndex;
                              if (isCorrect) {
                                benar++;
                              } else {
                                salah++;
                              }
                              timer?.cancel();
                              showAnswerDialog(isCorrect, selectedIndex);
                            },
                      child: const Text(
                        "Kirim Jawaban",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
