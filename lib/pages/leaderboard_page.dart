import 'package:flutter/material.dart';
import '../services/quiz_api.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  String selectedLevel = "Beginner";
  List<Map<String, dynamic>> leaderboardData = [];
  bool isLoading = true;
  Map<String, dynamic>? userProfile;

  final List<String> levels = [
    "Beginner",
    "Intermediate",
    "Advanced",
    "Expert",
  ];

  @override
  void initState() {
    super.initState();
    loadUserProfile();
    loadLeaderboard();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh leaderboard when returning to this page
    loadLeaderboard();
  }

  @override
  void didUpdateWidget(covariant LeaderboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh when widget updates (e.g., when navigating back)
    loadLeaderboard();
  }

  Future<void> loadUserProfile() async {
    try {
      final profile = await QuizApi.getUserProfile();
      setState(() {
        userProfile = profile;
      });
    } catch (e) {
      print("Error loading profile: $e");
    }
  }

  Future<void> loadLeaderboard() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Map level names to IDs (assuming 1=Beginner, 2=Intermediate, etc.)
      int levelId = levels.indexOf(selectedLevel) + 1;
      final data = await QuizApi.getLeaderboard(levelId);

      setState(() {
        leaderboardData = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading leaderboard: $e");
      setState(() {
        leaderboardData = [];
        isLoading = false;
      });
    }
  }

  void onLevelChanged(String? newLevel) {
    if (newLevel != null && newLevel != selectedLevel) {
      setState(() {
        selectedLevel = newLevel;
      });
      loadLeaderboard();
    }
  }

  Widget buildPodium() {
    if (leaderboardData.length < 3) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          buildPodiumItem(leaderboardData[1], 2, 80),
          const SizedBox(width: 10),
          // 1st place
          buildPodiumItem(leaderboardData[0], 1, 100),
          const SizedBox(width: 10),
          // 3rd place
          buildPodiumItem(leaderboardData[2], 3, 60),
        ],
      ),
    );
  }

  Widget buildPodiumItem(
    Map<String, dynamic> player,
    int position,
    double height,
  ) {
    final colors = {1: Colors.amber, 2: Colors.grey, 3: Colors.brown};

    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: colors[position] ?? Colors.grey,
          child: Text(
            player['name']?.substring(0, 1).toUpperCase() ?? '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          player['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${player['score'] ?? 0}',
          style: TextStyle(
            color: colors[position],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color:
                colors[position]?.withOpacity(0.8) ??
                Colors.grey.withOpacity(0.8),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              '$position',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLeaderboardTable() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.brown,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Rank',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Nama Peserta',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Level Quiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Skor',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (leaderboardData.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Belum ada data leaderboard untuk level ini',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...leaderboardData.map((player) {
              final rank = leaderboardData.indexOf(player) + 1;
              final isCurrentUser =
                  userProfile != null &&
                  player['user_id'] == userProfile!['id'];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.brown.shade50 : Colors.white,
                  border: const Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: rank <= 3
                              ? Colors.amber.shade700
                              : Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        player['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: isCurrentUser
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    Expanded(flex: 2, child: Text(selectedLevel)),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${player['score'] ?? 0}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget buildUserPosition() {
    if (userProfile == null || leaderboardData.isEmpty) {
      return const SizedBox.shrink();
    }

    final userIndex = leaderboardData.indexWhere(
      (player) => player['user_id'] == userProfile!['id'],
    );

    if (userIndex == -1) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Anda belum menyelesaikan quiz untuk level ini',
          style: TextStyle(color: Colors.blue),
        ),
      );
    }

    final rank = userIndex + 1;
    final player = leaderboardData[userIndex];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Posisi Anda: Rank $rank dengan skor ${player['score'] ?? 0}',
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        backgroundColor: Colors.brown.shade700,
        title: const Text('Leaderboard'),
        centerTitle: true,
        elevation: 4,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadLeaderboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            '🏆 LEADERBOARD',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.brown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Leaderboard Wayang',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lihat peringkat pemain terbaik dalam quiz wayang kulit. Pilih level untuk melihat leaderboard spesifik.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButton<String>(
                              value: selectedLevel,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: levels.map((level) {
                                return DropdownMenuItem(
                                  value: level,
                                  child: Text(level),
                                );
                              }).toList(),
                              onChanged: onLevelChanged,
                            ),
                          ),
                        ],
                      ),
                    ),
                    buildPodium(),
                    buildLeaderboardTable(),
                    buildUserPosition(),
                  ],
                ),
              ),
            ),
    );
  }
}
