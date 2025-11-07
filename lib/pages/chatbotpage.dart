import 'package:flutter/material.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];

  final ScrollController scrollController = ScrollController();

  bool isBotTyping = false;

  // Animasi titik-titik
  late AnimationController _typingController;
  late Animation<int> _dotsAnimation;

  @override
  void initState() {
    super.initState();

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();

    _dotsAnimation = StepTween(begin: 0, end: 3).animate(_typingController);
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": text});
      controller.clear();
      isBotTyping = true;
    });

    scrollToBottom();

    // Simulasi bot reply
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        messages.add({
          "sender": "bot",
          "text": "Ini jawaban otomatis dari bot untuk: $text"
        });
        isBotTyping = false;
      });

      scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ HEADER LEBIH RAPIH
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // Tombol back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xffC48A68),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 18),

                  const Text(
                    "ChatBot",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ✅ BODY
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                ...messages.map((msg) {
                  bool isUser = msg["sender"] == "user";

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment:
                          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          constraints: const BoxConstraints(maxWidth: 240),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.brown
                                : const Color(0xffE8D4BE),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            msg["text"],
                            style: TextStyle(
                              fontSize: 14,
                              color: isUser ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // BOT TYPING ANIMATION
                if (isBotTyping)
                  AnimatedBuilder(
                    animation: _dotsAnimation,
                    builder: (_, __) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xffE8D4BE),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              "Bot sedang mengetik${"." * _dotsAnimation.value}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),

          // INPUT BAR 
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TextField(
                      controller: controller,

                      // ✅ Biar 1 baris saja & enter langsung kirim
                      maxLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => sendMessage(),

                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Masukkan pertanyaan Anda...",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.send,
                      color: Colors.brown,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}