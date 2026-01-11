import 'package:flutter/material.dart';

class ArticleDetailPage extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. App Bar dengan Gambar
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF4B3425),
            flexibleSpace: FlexibleSpaceBar(
              background: article['thumbnail'] != null
                  ? Image.network(
                      article['thumbnail'],
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, _) => Container(color: Colors.grey),
                    )
                  : Container(color: Colors.grey, child: const Icon(Icons.article, size: 50)),
            ),
          ),

          // 2. Isi Konten
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    article['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B3425),
                      fontFamily: 'Serif',
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Tanggal
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        article['created_at'] ?? '-',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  // Isi Artikel
                  Text(
                    article['content_full'] ?? article['content_preview'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Sumber Link (Jika ada)
                  if (article['source_link'] != null && article['source_link'] != '')
                    Text(
                      "Sumber: ${article['source_link']}",
                      style: const TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}