import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // --- CONFIG MODE AI ---
  bool isGeminiMode = false;

  // --- PALET WARNA ---
  Color get primaryColor => isGeminiMode ? const Color(0xFF1B5E20) : const Color(0xFFD4A373);
  Color get accentColor => isGeminiMode ? const Color(0xFF81C784) : const Color(0xFF4B3425);
  final Color surfaceColor = const Color(0xFFFDFBF7);

  final List<Map<String, dynamic>> _messages = [
    {
      "text": "Sampurasun! 👋\nKenalin inyong Cepot. Ana sing bisa dibantu?",
      "isUser": false,
      "time": "Sekarang"
    }
  ];

  final List<String> _quickReplies = [
    "Apa itu Wayang?",
    "Tokoh Pandawa",
    "Filosofi Semar",
    "Cerita Ramayana"
  ];

  bool _isTyping = false;
  late AnimationController _typingController;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"text": text, "isUser": true, "time": _getCurrentTime()});
      _isTyping = true;
    });

    _textController.clear();
    _scrollToBottom();

    String modeToSend = isGeminiMode ? 'gemini' : 'rag';

    try {
      final reply = await ApiService.sendMessageSmart(text, modeToSend);
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            "text": reply ?? "Waduh, Cepot lagi pusing euy (Error koneksi).",
            "isUser": false,
            "time": _getCurrentTime()
          });
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({"text": "Aduh, sistem lagi error euy.", "isUser": false, "time": _getCurrentTime()});
        });
      }
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: surfaceColor,
        appBar: _buildModernAppBar(),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildWatermark(),
                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
                ],
              ),
            ),
            if (!isGeminiMode) _buildQuickReplies(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      toolbarHeight: 80,
      backgroundColor: primaryColor,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, accentColor],
          ),
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: const NetworkImage('https://cdn-icons-png.flaticon.com/512/4712/4712035.png'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Cepot AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Text(isGeminiMode ? "Mode Gemini" : "Mode Wayanusa", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isGeminiMode,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.greenAccent.withOpacity(0.5),
                  onChanged: (v) => setState(() => isGeminiMode = v),
                ),
              ),
              const Text("Mode", style: TextStyle(color: Colors.white, fontSize: 10)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildWatermark() {
    return Center(
      child: Opacity(
        opacity: 0.03,
        child: Image.network('https://cdn-icons-png.flaticon.com/512/4712/4712035.png', width: 250),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isUser = msg['isUser'];
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 5),
            bottomRight: Radius.circular(isUser ? 5 : 20),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg['text'],
              style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(msg['time'], style: TextStyle(color: isUser ? Colors.white60 : Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReplies() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _quickReplies.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              backgroundColor: Colors.white,
              side: BorderSide(color: primaryColor.withOpacity(0.2)),
              label: Text(_quickReplies[index], style: TextStyle(color: primaryColor, fontSize: 12)),
              onPressed: () => _sendMessage(_quickReplies[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(25)),
              child: TextField(
                controller: _textController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(hintText: "Tanya Cepot...", border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: primaryColor,
            radius: 25,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: () => _sendMessage(_textController.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => FadeTransition(
            opacity: Tween(begin: 0.2, end: 1.0).animate(CurvedAnimation(parent: _typingController, curve: Interval(i * 0.2, 0.6 + i * 0.2))),
            child: Container(width: 6, height: 6, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
          )),
        ),
      ),
    );
  }
}