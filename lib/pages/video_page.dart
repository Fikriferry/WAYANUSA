import 'package:flutter/material.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final TextEditingController searchController = TextEditingController();

  // Data dummy video
  final List<Map<String, String>> videos = [
    {
      "title": "BAGONG LAWAN LUPIT UNTUK MEREBUTKAN KEKUASAAN",
      "source": "Wayang Indonesia",
      "thumbnail": "assets/thumbnail1.png",
    },
    {
      "title": "SEMARAMA DAN PETRUK DALAM KISAH KLASIK WAYANG",
      "source": "Wayang Nusantara",
      "thumbnail": "assets/thumbnail2.png",
    },
    {
      "title": "BAGONG LAWAN LUPIT UNTUK MEREBUTKAN KEKUASAAN",
      "source": "Wayang Indonesia",
      "thumbnail": "assets/thumbnail3.png",
    },
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // filter video berdasarkan pencarian
    final filteredVideos = videos
        .where((video) => video["title"]!
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFB6783D), // warna coklat seperti desain login
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Video',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // Kolom pencarian
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) => setState(() {
                  searchQuery = value;
                }),
                decoration: const InputDecoration(
                  hintText: 'Cari Video',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Daftar video
            Expanded(
              child: ListView.builder(
                itemCount: filteredVideos.length,
                itemBuilder: (context, index) {
                  final video = filteredVideos[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail video
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: AssetImage(video["thumbnail"]!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          video["title"]!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          video["source"]!,
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
