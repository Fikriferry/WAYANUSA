import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../services/api_service.dart';

class ArticleDetailPage extends StatefulWidget {
  final Map<String, dynamic> article;

  const ArticleDetailPage({
    super.key,
    required this.article,
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  Map<String, dynamic>? fullArticle;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.article['content_full'] == null && widget.article['id'] != null) {
      fetchFullArticle();
    }
  }

  void fetchFullArticle() async {
    setState(() {
      isLoading = true;
    });
    final data = await ApiService.getArticle(widget.article['id']);
    if (mounted) {
      setState(() {
        fullArticle = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = fullArticle ?? widget.article;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4A373)))
          : CustomScrollView(
              slivers: [
                // ================= APP BAR DENGAN GAMBAR =================
                SliverAppBar(
                  expandedHeight: 250.0,
                  pinned: true,
                  backgroundColor: const Color(0xFF4B3425),
                  flexibleSpace: FlexibleSpaceBar(
                    background: article['thumbnail'] != null &&
                            article['thumbnail'].toString().isNotEmpty
                        ? Image.network(
                            article['thumbnail'],
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, _) =>
                                Container(color: Colors.grey),
                          )
                        : Container(
                            color: Colors.grey,
                            child: const Icon(
                              Icons.article,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                // ================= ISI ARTIKEL (FULL, TANPA BATAS) =================
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // JUDUL
                        Text(
                          article['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B3425),
                            fontFamily: 'Serif',
                          ),
                        ),

                        const SizedBox(height: 10),

                        // TANGGAL
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              article['created_at'] ?? '-',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 30),

                        // ================= KONTEN ARTIKEL =================
                        Text(
                          article['content'] ??
                              article['content_full'] ??
                              article['content_preview'] ??
                              '',
                          softWrap: true,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.7,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ================= SUMBER (JIKA ADA) =================
                        if (article['source_link'] != null &&
                            article['source_link'].toString().isNotEmpty)
                          Text(
                            "Sumber: ${article['source_link']}",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
