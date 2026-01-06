import 'package:flutter/material.dart';
import '../services/quiz_api.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with SingleTickerProviderStateMixin {
  // Palet Warna
  final Color primaryColor = const Color(0xFFD4A373);
  final Color secondaryColor = const Color(0xFF4B3425);
  final Color surfaceColor = const Color(0xFFF9F9F9);
  final Color goldColor = const Color(0xFFFFD700);
  final Color silverColor = const Color(0xFFC0C0C0);
  final Color bronzeColor = const Color(0xFFCD7F32);

  String selectedLevel = "Beginner";
  List<Map<String, dynamic>> leaderboardData = [];
  bool isLoading = true;
  Map<String, dynamic>? userProfile;
  
  // Animasi Podium
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<String> levels = [
    "Beginner", "Intermediate", "Advanced", "Expert"
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    
    loadUserProfile();
    loadLeaderboard();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> loadUserProfile() async {
    try {
      final profile = await QuizApi.getUserProfile();
      if(mounted) setState(() => userProfile = profile);
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  Future<void> loadLeaderboard() async {
    if(mounted) setState(() => isLoading = true);
    _animController.reset(); // Reset animasi

    try {
      int levelId = levels.indexOf(selectedLevel) + 1;
      final data = await QuizApi.getLeaderboard(levelId);

      if(mounted) {
        setState(() {
          leaderboardData = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
        _animController.forward(); // Jalankan animasi podium
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          leaderboardData = [];
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text("Papan Peringkat", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: secondaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. HEADER & LEVEL SELECTOR
          _buildHeaderSection(),

          // 2. CONTENT (Podium & List)
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : leaderboardData.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: loadLeaderboard,
                        color: primaryColor,
                        child: CustomScrollView(
                          slivers: [
                            // Podium Top 3
                            SliverToBoxAdapter(child: _buildPodiumSection()),
                            
                            // Title List
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Text(
                                  "Peringkat Lainnya",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                              ),
                            ),

                            // List Rank 4 dst
                            SliverPadding(
                              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100), // Bottom padding for floating bar
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    // Skip Top 3 (index 0,1,2 sudah di podium)
                                    if (index < 3) return const SizedBox.shrink();
                                    return _buildRankItem(leaderboardData[index], index + 1);
                                  },
                                  childCount: leaderboardData.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
      
      // 3. FLOATING MY RANK (Sticky Bottom)
      bottomSheet: !isLoading && leaderboardData.isNotEmpty 
          ? _buildMyRankBar() 
          : null,
    );
  }

  // ================= SECTION WIDGETS =================

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: secondaryColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          // Level Selector (Horizontal Scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: levels.map((level) {
                final bool isSelected = selectedLevel == level;
                return GestureDetector(
                  onTap: () {
                    if (!isSelected) {
                      setState(() => selectedLevel = level);
                      loadLeaderboard();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.white.withOpacity(0.3)
                      ),
                    ),
                    child: Text(
                      level,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumSection() {
    if (leaderboardData.isEmpty) return const SizedBox.shrink();

    // Data Top 3
    final first = leaderboardData.isNotEmpty ? leaderboardData[0] : null;
    final second = leaderboardData.length > 1 ? leaderboardData[1] : null;
    final third = leaderboardData.length > 2 ? leaderboardData[2] : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: ScaleTransition(
        scale: _fadeAnim,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // JUARA 2
            if (second != null) 
              Expanded(child: _buildPodiumColumn(second, 2, silverColor, 120)),
            
            // JUARA 1 (Tengah & Paling Tinggi)
            if (first != null) 
              Expanded(child: _buildPodiumColumn(first, 1, goldColor, 160)),
            
            // JUARA 3
            if (third != null) 
              Expanded(child: _buildPodiumColumn(third, 3, bronzeColor, 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumColumn(Map<String, dynamic> player, int rank, Color color, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 32 : 26,
                backgroundColor: color.withOpacity(0.2),
                child: Text(
                  player['name']?[0].toUpperCase() ?? "?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: secondaryColor),
                ),
              ),
            ),
            // Crown Icon untuk Juara 1
            if (rank == 1)
              const Positioned(
                top: -24,
                child: Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 30),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Nama
        Text(
          player['name'] ?? "Unknown",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        // Skor
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "${player['score']}",
            style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ),

        // Batang Podium
        Container(
          width: double.infinity,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$rank",
                style: const TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.w900, 
                  fontSize: 32
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankItem(Map<String, dynamic> player, int rank) {
    bool isMe = (userProfile != null && player['user_id'] == userProfile!['id']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isMe ? primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMe ? Border.all(color: primaryColor) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Text(
            "#$rank",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
        ),
        title: Text(
          player['name'] ?? "Unknown",
          style: TextStyle(fontWeight: FontWeight.bold, color: secondaryColor),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "${player['score']} Pts",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }

  // Bar Melayang di Bawah (Sticky User Rank)
  Widget _buildMyRankBar() {
    if (userProfile == null) return const SizedBox.shrink();

    // Cari posisi user di list
    final userIndex = leaderboardData.indexWhere((p) => p['user_id'] == userProfile!['id']);
    
    // Default jika user tidak ada di leaderboard (belum main)
    String rankStr = "-";
    String scoreStr = "0";
    
    if (userIndex != -1) {
      rankStr = "#${userIndex + 1}";
      scoreStr = "${leaderboardData[userIndex]['score']}";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF4B3425),
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Peringkat Kamu", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    userProfile!['name'] ?? "User",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rankStr,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFFD4A373)),
                ),
                Text(
                  "$scoreStr Pts",
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/icon_quiz.png", height: 80, color: Colors.grey[300]), // Placeholder
          const SizedBox(height: 16),
          const Text("Belum ada jawara di level ini!", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}