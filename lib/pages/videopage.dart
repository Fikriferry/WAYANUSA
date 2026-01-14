import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../services/api_service.dart';

/// =====================================================
/// VIDEO PAGE
/// Fungsi:
/// - Menampilkan video YouTube dari API
/// - Memutar video wayang
/// - Search / filter judul video
/// - UI modern + player terintegrasi
/// =====================================================
class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {

  /// -------------------------------------------------
  /// YOUTUBE CONTROLLER
  /// Digunakan untuk mengontrol player YouTube
  /// (play, pause, load video, dll)
  /// -------------------------------------------------
  late YoutubePlayerController _controller;

  /// Controller untuk input search
  final TextEditingController searchController = TextEditingController();

  /// -------------------------------------------------
  /// STATE DATA
  /// allVideos      : semua video dari API
  /// filteredVideos : hasil filter search
  /// isLoading      : status loading API
  /// -------------------------------------------------
  List<dynamic> allVideos = [];
  List<dynamic> filteredVideos = [];
  bool isLoading = true;

  /// -------------------------------------------------
  /// WARNA TEMA APLIKASI
  /// -------------------------------------------------
  final Color primaryColor = const Color(0xFFB6783D);
  final Color accentColor = const Color(0xFF8D5B2B);
  final Color bgColor = const Color(0xFFF8F9FD);

  /// =====================================================
  /// INIT STATE
  /// Dipanggil saat halaman pertama kali dibuka
  /// =====================================================
  @override
  void initState() {
    super.initState();
    fetchVideos(); // Ambil data video dari API
  }

  /// =====================================================
  /// FETCH VIDEOS
  /// - Ambil data video dari backend
  /// - Set controller YouTube
  /// =====================================================
  void fetchVideos() async {
    final videos = await ApiService.getVideos();

    /// DEBUG LOG (untuk cek isi API)
    if (videos.isNotEmpty) {
      print("🔍 VIDEO PERTAMA:");
      print("Judul: ${videos[0]['title']}");
      print("Youtube ID: ${videos[0]['youtube_id']}");
    }

    /// Pastikan widget masih aktif
    if (mounted) {
      setState(() {
        allVideos = videos;
        filteredVideos = videos;
        isLoading = false;

        /// Jika ada video → set video pertama sebagai default
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
          /// Jika tidak ada video
          _controller = YoutubePlayerController(initialVideoId: "");
        }
      });
    }
  }

  /// =====================================================
  /// FILTER SEARCH VIDEO
  /// =====================================================
  void _runFilter(String keyword) {
    List<dynamic> results;

    if (keyword.isEmpty) {
      results = allVideos;
    } else {
      results = allVideos
          .where((video) =>
              video['title']
                  .toLowerCase()
                  .contains(keyword.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredVideos = results;
    });
  }

  /// =====================================================
  /// GANTI VIDEO YANG DIPUTAR
  /// =====================================================
  void _changeVideo(String videoId) {
    _controller.load(videoId);
    _controller.play();
    FocusScope.of(context).unfocus(); // Tutup keyboard
  }

  /// =====================================================
  /// PAUSE VIDEO SAAT PAGE TIDAK AKTIF
  /// =====================================================
  @override
  void deactivate() {
    if (allVideos.isNotEmpty) _controller.pause();
    super.deactivate();
  }

  /// =====================================================
  /// DISPOSE CONTROLLER
  /// =====================================================
  @override
  void dispose() {
    if (allVideos.isNotEmpty) _controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  /// =====================================================
  /// BUILD UI
  /// =====================================================
  @override
  Widget build(BuildContext context) {

    /// Loading state
    if (isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    /// YoutubePlayerBuilder
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: primaryColor,

        /// Judul di atas video
        topActions: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _controller.metadata.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),

      /// =================================================
      /// BUILDER UI UTAMA
      /// =================================================
      builder: (context, player) {
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [

                /// ================= VIDEO PLAYER =================
                Stack(
                  children: [
                    player,

                    /// Tombol back floating
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
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                /// ================= SEARCH & LIST =================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// INFO VIDEO AKTIF
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Sedang Diputar",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.theater_comedy,
                                      color: primaryColor),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _controller.metadata.title.isEmpty
                                    ? "Memuat Wayang..."
                                    : _controller.metadata.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _controller.metadata.author.isEmpty
                                    ? "Wayanusa Official"
                                    : _controller.metadata.author,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      /// SEARCH BAR
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
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: primaryColor,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// LIST VIDEO
                      Expanded(
                        child: filteredVideos.isEmpty
                            ? const Center(
                                child: Text("Tidak ditemukan"),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                itemCount: filteredVideos.length,
                                itemBuilder: (context, index) {
                                  final video = filteredVideos[index];
                                  final isPlaying =
                                      _controller.metadata.videoId ==
                                          video['youtube_id'];

                                  return GestureDetector(
                                    onTap: () =>
                                        _changeVideo(video['youtube_id']),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      margin:
                                          const EdgeInsets.only(bottom: 15),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isPlaying
                                            ? const Color(0xFFFFF8E1)
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15),
                                        border: isPlaying
                                            ? Border.all(
                                                color: primaryColor, width: 1.5)
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          /// THUMBNAIL
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              video['thumbnail'],
                                              width: 100,
                                              height: 70,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 15),

                                          /// JUDUL VIDEO
                                          Expanded(
                                            child: Text(
                                              video['title'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: isPlaying
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                                color: isPlaying
                                                    ? accentColor
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),

                                          if (!isPlaying)
                                            const Icon(
                                              Icons.play_arrow_rounded,
                                              color: Colors.grey,
                                            ),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
