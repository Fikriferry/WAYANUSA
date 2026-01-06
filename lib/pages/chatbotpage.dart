import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // --- PALET WARNA MODERN HERITAGE ---
  final Color primaryColor = const Color(0xFFD4A373); // Emas Wayang
  final Color secondaryColor = const Color(0xFF8D6E63); // Coklat Kayu
  final Color surfaceColor = const Color(0xFFFDFBF7); // Krem Kertas Tua
  final Color myBubbleColor = const Color(0xFFB88656); // Warna Bubble User

  // List Pesan
  final List<Map<String, dynamic>> _messages = [
    {
      "text": "Sampurasun! 👋\nKenalin inyong Cepot. Ana sing bisa dibantu?",
      "isUser": false,
      "time": "Baru saja"
    }
  ];

  final List<String> _quickReplies = [
    "Apa itu Wayang?",
    "Siapa tokoh Pandawa?",
    "Rekomendasi cerita",
    "Filosofi Semar"
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

  // --- LOGIC KIRIM PESAN ---
  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        "text": text,
        "isUser": true,
        "time": _getCurrentTime()
      });
      _isTyping = true;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      final reply = await ApiService.sendMessage(text);
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            "text": reply ?? "Maaf, Cepot lagi pusing (Error koneksi).",
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
          _messages.add({
            "text": "Waduh, error sistem euy.",
            "isUser": false,
            "time": _getCurrentTime()
          });
        });
      }
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  // --- BUILD UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      // Stack digunakan untuk menaruh Watermark di belakang chat
      body: Stack(
        children: [
          // 1. BACKGROUND WATERMARK (Agar tidak sepi)
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.05, // Sangat transparan
                child: Image.network(
                  'https://cdn-icons-png.flaticon.com/512/4712/4712035.png',
                  width: 300,
                  height: 300,
                  color: Colors.brown, // Tint warna coklat
                ),
              ),
            ),
          ),

          // 2. KONTEN UTAMA
          Column(
            children: [
              _buildCustomHeader(context), // Header Baru
              
              // LIST PESAN
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageRow(_messages[index]);
                  },
                ),
              ),

              // QUICK REPLIES
              Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _quickReplies.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ActionChip(
                        label: Text(_quickReplies[index]),
                        labelStyle: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: primaryColor.withOpacity(0.5)),
                        shadowColor: Colors.black12,
                        elevation: 2,
                        shape: const StadiumBorder(),
                        onPressed: () => _sendMessage(_quickReplies[index]),
                      ),
                    );
                  },
                ),
              ),

              // INPUT FIELD AREA
              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  // WIDGET: Custom Header dengan tombol Back
  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 10, right: 20, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, secondaryColor],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: secondaryColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // TOMBOL BACK
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context), // Kembali ke Homepage
          ),
          
          // Avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/4712/4712035.png'),
            ),
          ),
          const SizedBox(width: 12),
          
          // Info Bot
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cepot AI",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: Color(0xFF2ECC71), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  const Text("Online", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              )
            ],
          ),
          const Spacer(),
          // Icon hiasan
          Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.2), size: 30),
        ],
      ),
    );
  }

  // WIDGET: Area Input Modern (Floating)
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 20), // Padding bawah agak besar
      decoration: BoxDecoration(
        color: surfaceColor,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: "Tanya Ki Sabda...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                ),
                onSubmitted: _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: () => _sendMessage(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: Chat Bubble
  Widget _buildMessageRow(Map<String, dynamic> msg) {
    final isUser = msg['isUser'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/4712/4712035.png'),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                // Gradient untuk user, Putih untuk bot
                gradient: isUser 
                    ? LinearGradient(colors: [primaryColor, myBubbleColor]) 
                    : null,
                color: isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    msg['text'],
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF4A4A4A),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg['time'] ?? "",
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Typing Indicator
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 36),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return FadeTransition(
              opacity: Tween(begin: 0.2, end: 1.0).animate(
                CurvedAnimation(
                  parent: _typingController,
                  curve: Interval(index * 0.2, 0.6 + index * 0.2, curve: Curves.easeInOut),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6, height: 6,
                decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
              ),
            );
          }),
        ),
      ),
    );
  }
}