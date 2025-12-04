import 'dart:async';
import 'package:flutter/material.dart';

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

  final List<Map<String, dynamic>> questions = [
    {
      "question":
          "Siapakah tokoh utama dalam kisah Mahabharata yang dikenal sebagai pemanah ulung dan murid kesayangan Drona?",
      "options": ["Bima", "Nakula", "Arjuna", "Karna"],
      "answer": 2,
    },
    {
      "question": "Wayang berasal dari kebudayaan negara mana?",
      "options": ["India", "Indonesia", "Thailand", "Malaysia"],
      "answer": 1,
    },
    {
      "question":
          "Tokoh wayang berwajah hitam dan dikenal sebagai kuat adalah?",
      "options": ["Arjuna", "Yudhistira", "Bima", "Kresna"],
      "answer": 2,
    },
    {
      "question": "Siapa raja dari kerajaan Astina?",
      "options": ["Duryudana", "Abimanyu", "Puntadewa", "Baladewa"],
      "answer": 0,
    },
    {
      "question": "Dalang dalam pertunjukan wayang berfungsi sebagai?",
      "options": [
        "Pemain gamelan",
        "Penyanyi",
        "Pengendali cerita dan suara",
        "Penari",
      ],
      "answer": 2,
    },
    {
      "question": "Wayang kulit terbuat dari bahan apa?",
      "options": ["Kayu", "Kertas", "Kulit kerbau", "Bambu"],
      "answer": 2,
    },
    {
      "question": "Wayang digunakan untuk menyampaikan?",
      "options": ["Pesan moral", "Iklan", "Berita", "Tantangan"],
      "answer": 0,
    },
    {
      "question": "Siapa dewa tertinggi dalam pewayangan?",
      "options": [
        "Batara Guru",
        "Batara Narada",
        "Batara Indra",
        "Batara Surya",
      ],
      "answer": 0,
    },
    {
      "question": "Siapakah ayah dari Gatutkaca?",
      "options": ["Arjuna", "Nakula", "Bima", "Kresna"],
      "answer": 2,
    },
    {
      "question": "Siapakah dalang terkenal asal Indonesia?",
      "options": ["Ki Manteb Sudharsono", "Ki Sugino", "Ki Cakra", "Ki Warno"],
      "answer": 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
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

  void showFinalScore() {
    int nilai = (benar / questions.length * 100).round();

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
              Navigator.pop(context);
            },
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
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
    final question = questions[currentQuestionIndex];
    final options = question["options"] as List<String>;

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
        body: Padding(
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
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                shadowColor: Colors.brown.shade200,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    question["question"],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(options.length, (index) {
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    height: 60,  // ✨ fixed height untuk semua opsi
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.brown.shade400 : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? Colors.brown : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          offset: const Offset(2, 2),
                          color: Colors.black.withOpacity(0.05),
                        )
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        options[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade700,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                ),
                onPressed: selectedIndex == -1
                    ? null
                    : () {
                        final correctIndex = question["answer"] as int;
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
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}