import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../services/api_service.dart';

class VideoPage extends StatefulWidget {
  final Future<List<dynamic>> Function()? fetchVideosFn;
  final bool disablePlayer;

  const VideoPage({super.key, this.fetchVideosFn, this.disablePlayer = false});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  YoutubePlayerController? _controller;
  final TextEditingController searchController = TextEditingController();

  List<dynamic> allVideos = [];
  List<dynamic> filteredVideos = [];
  bool isLoading = true;

  final Color primaryColor = const Color(0xFFB6783D);
  final Color accentColor = const Color(0xFF8D5B2B);
  final Color bgColor = const Color(0xFFF8F9FD);

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  void fetchVideos() async {
    final videos = widget.fetchVideosFn != null
        ? await widget.fetchVideosFn!()
        : await ApiService.getVideos();

    if (!mounted) return;

    setState(() {
      allVideos = videos;
      filteredVideos = videos;
      isLoading = false;

      if (!widget.disablePlayer && videos.isNotEmpty) {
        _controller = YoutubePlayerController(
          initialVideoId: videos[0]['youtube_id'],
          flags: const YoutubePlayerFlags(autoPlay: false),
        );
      }
    });
  }

  void _runFilter(String keyword) {
    final results = keyword.isEmpty
        ? allVideos
        : allVideos
            .where((video) =>
                video['title'].toLowerCase().contains(keyword.toLowerCase()))
            .toList();

    setState(() => filteredVideos = results);
  }

  void _changeVideo(String videoId) {
    _controller?.load(videoId);
    _controller?.play();
    FocusScope.of(context).unfocus();
  }

  @override
  void deactivate() {
    _controller?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller?.dispose();
    searchController.dispose();
    super.dispose();
  }

  Widget _buildTestUI() {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 80),
          const Text("PLAYER DISABLED (TEST MODE)"),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: _runFilter,
              decoration: const InputDecoration(
                hintText: "Cari video...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredVideos.length,
              itemBuilder: (context, index) {
                final video = filteredVideos[index];
                return ListTile(title: Text(video['title']));
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (widget.disablePlayer) return _buildTestUI();

    if (_controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: primaryColor,
        topActions: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _controller?.metadata.title ?? "No Title",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 18),
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
                Stack(
                  children: [
                    player,
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
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: searchController,
                          onChanged: _runFilter,
                          decoration: InputDecoration(
                            hintText: 'Cari lakon wayang...',
                            prefixIcon: Icon(Icons.search, color: primaryColor),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredVideos.length,
                          itemBuilder: (context, index) {
                            final video = filteredVideos[index];
                            final isPlaying =
                                _controller?.metadata.videoId ==
                                    video['youtube_id'];

                            return ListTile(
                              leading: Image.network(video['thumbnail'],
                                  width: 100, fit: BoxFit.cover),
                              title: Text(video['title']),
                              trailing: isPlaying
                                  ? const Icon(Icons.play_circle_fill)
                                  : const Icon(Icons.play_arrow),
                              onTap: () =>
                                  _changeVideo(video['youtube_id']),
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