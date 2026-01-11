import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../services/api_service.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late YoutubePlayerController _controller;
  final TextEditingController searchController = TextEditingController();

  // Data State
  List<dynamic> allVideos = [];
  List<dynamic> filteredVideos = [];
  bool isLoading = true;
  
  // Warna Tema (Golden Brown & Dark)
  final Color primaryColor = const Color(0xFFB6783D);
  final Color accentColor = const Color(0xFF8D5B2B);
  final Color bgColor = const Color(0xFFF8F9FD);

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  void fetchVideos() async {
    final videos = await ApiService.getVideos();

    // TAMBAHKAN INI UNTUK CEK LOG
    if (videos.isNotEmpty) {
      print("🔍 VIDEO PERTAMA DARI API:");
      print("Title: ${videos[0]['title']}");
      print("Youtube ID: ${videos[0]['youtube_id']}"); // Cek apakah ID-nya aneh?
    }
    
    if (mounted) {
      setState(() {
        allVideos = videos;
        filteredVideos = videos;
        isLoading = false;

        if (allVideos.isNotEmpty) {
          _controller = YoutubePlayerController(
            initialVideoId: allVideos[0]['youtube_id'],
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              isLive: false,
              forceHD: false,
            ),
          );
        } else {
          _controller = YoutubePlayerController(initialVideoId: ""); 
        }
      });
    }
  }

  void _runFilter(String enteredKeyword) {
    List<dynamic> results = [];
    if (enteredKeyword.isEmpty) {
      results = allVideos;
    } else {
      results = allVideos
          .where((video) =>
              video["title"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      filteredVideos = results;
    });
  }

  void _changeVideo(String videoId) {
    _controller.load(videoId);
    _controller.play();
    FocusScope.of(context).unfocus();
  }

  @override
  void deactivate() {
    if (allVideos.isNotEmpty) _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    if (allVideos.isNotEmpty) _controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: primaryColor,
        topActions: [
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                // 1. VIDEO PLAYER SECTION
                Stack(
                  children: [
                    player,
                    // Custom Back Button di atas Video (Floating)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. SEARCH & LIST SECTION
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // Header Info Video Aktif
                        if (allVideos.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ],
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(25),
                                bottomRight: Radius.circular(25),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Sedang Diputar",
                                        style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.theater_comedy, color: primaryColor, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _controller.metadata.title.isEmpty
                                      ? "Memuat Wayang..."
                                      : _controller.metadata.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _controller.metadata.author.isEmpty ? "Wayanusa Official" : _controller.metadata.author,
                                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Search Bar Modern
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: searchController,
                              onChanged: _runFilter,
                              decoration: InputDecoration(
                                hintText: 'Cari lakon wayang...',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        
                        // Label List
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Daftar Lakon (${filteredVideos.length})",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // List Video Cards
                        Expanded(
                          child: filteredVideos.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                                      const SizedBox(height: 10),
                                      Text("Tidak ditemukan", style: TextStyle(color: Colors.grey[400])),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                  itemCount: filteredVideos.length,
                                  itemBuilder: (context, index) {
                                    final video = filteredVideos[index];
                                    final isPlaying = _controller.metadata.videoId == video['youtube_id'];

                                    return GestureDetector(
                                      onTap: () => _changeVideo(video['youtube_id']),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.only(bottom: 15),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isPlaying ? const Color(0xFFFFF8E1) : Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          border: isPlaying 
                                              ? Border.all(color: primaryColor, width: 1.5) 
                                              : Border.all(color: Colors.transparent),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.03),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            // Thumbnail Image
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Image.network(
                                                    video['thumbnail'],
                                                    width: 100,
                                                    height: 70,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (ctx, err, _) => Container(
                                                      width: 100, height: 70, color: Colors.grey[300],
                                                      child: const Icon(Icons.broken_image, size: 20),
                                                    ),
                                                  ),
                                                ),
                                                // Overlay jika sedang main
                                                if (isPlaying)
                                                  Container(
                                                    width: 100, height: 70,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.4),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: const Icon(Icons.bar_chart, color: Colors.white),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(width: 15),
                                            
                                            // Title & Info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    video['title'],
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: isPlaying ? FontWeight.bold : FontWeight.w600,
                                                      color: isPlaying ? accentColor : Colors.black87,
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.play_circle_outline, size: 12, color: Colors.grey[500]),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        "Tonton Sekarang",
                                                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),

                                            // Icon Play di Kanan
                                            if (!isPlaying)
                                              Icon(Icons.play_arrow_rounded, color: Colors.grey[300]),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}