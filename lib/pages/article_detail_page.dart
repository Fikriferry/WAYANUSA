import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'; // GANTI flutter_html KE INI
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart'; // Install: flutter pub add share_plus
import 'package:intl/intl.dart'; // Install: flutter pub add intl
import '../services/api_service.dart';

class ArticleDetailPage extends StatefulWidget {
  final Map<String, dynamic> article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  Map<String, dynamic>? fullArticle;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Jika konten lengkap belum ada, fetch dari API
    if (widget.article['content'] == null && widget.article['id'] != null) {
      fetchFullArticle();
    } else {
      fullArticle = widget.article; // Pakai data yang sudah ada
    }
  }

  void fetchFullArticle() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getArticle(widget.article['id']);
      if (mounted) {
        setState(() {
          fullArticle = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      print("Error fetching article: $e");
    }
  }

  // Helper: Hitung Estimasi Waktu Baca
  String _calculateReadTime(String text) {
    final wordCount = text.split(RegExp(r'\s+')).length;
    final readTime = (wordCount / 200).ceil(); // Asumsi 200 kata/menit
    return "$readTime min read";
  }

  // Helper: Format Tanggal Cantik
  String _formatDate(String? dateStr) {
    if (dateStr == null) return "Unknown Date";
    try {
      // Sesuaikan format input dari API kamu (contoh: "2024-01-20")
      // Jika format dari API adalah ISO 8601, pakai DateTime.parse(dateStr)
      // Disini saya asumsi inputnya String biasa, kita coba parse
      DateTime date = DateTime.tryParse(dateStr) ?? DateTime.now();
      return DateFormat('d MMMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = fullArticle ?? widget.article;
    final content = article['content'] ?? article['content_full'] ?? '';
    final title = article['title'] ?? 'No Title';
    final thumbnail = article['thumbnail'];
    final date = _formatDate(article['created_at']);
    final readTime = _calculateReadTime(content);

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4A373)),
            )
          : CustomScrollView(
              slivers: [
                // ================= APP BAR KEREN =================
                SliverAppBar(
                  expandedHeight: 300.0,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          // Fitur Share
                          Share.share(
                            '$title\n\nBaca selengkapnya di Wayanusa App!',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // GAMBAR UTAMA (Hero Animation)
                        Hero(
                          tag: 'article_img_${article['id']}',
                          child:
                              thumbnail != null &&
                                  thumbnail.toString().isNotEmpty
                              ? Image.network(
                                  thumbnail,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(color: Colors.grey[300]),
                                )
                              : Container(
                                  color: const Color(0xFF4B3425),
                                  child: const Icon(
                                    Icons.menu_book,
                                    size: 80,
                                    color: Colors.white24,
                                  ),
                                ),
                        ),
                        // GRADIENT OVERLAY (Biar ikon back kelihatan)
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black54,
                                Colors.transparent,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ================= ISI KONTEN =================
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 30,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    // Trik agar container naik sedikit menutupi gambar
                    transform: Matrix4.translationValues(0.0, -30.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BADGE KATEGORI (Opsional)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Wayang & Budaya",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB8860B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // JUDUL UTAMA
                        Text(
                          title,
                          style: GoogleFonts.merriweather(
                            // Font Serif elegan untuk judul
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            height: 1.3,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // INFO META (Penulis, Tanggal, Waktu Baca)
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey[300],
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/cepot_mascot.png',
                                  fit: BoxFit.cover,
                                  width: 36,
                                  height: 36,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tim Wayanusa",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      date,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.circle,
                                      size: 4,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      readTime,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                        const Divider(height: 1),
                        const SizedBox(height: 30),

                        // KONTEN ARTIKEL (HTML RENDERER)
                        // Menggunakan HtmlWidget agar gambar/bold/italic di dalam konten muncul
                        HtmlWidget(
                          content,
                          textStyle: GoogleFonts.merriweather(
                            // Font Serif enak untuk baca panjang
                            fontSize: 16,
                            height: 1.8,
                            color: const Color(0xFF424242),
                          ),
                          customStylesBuilder: (element) {
                            if (element.localName == 'p') {
                              return {'margin-bottom': '16px'};
                            }
                            return null;
                          },
                          // Mengatur styling gambar di dalam artikel agar rounded
                          enableCaching: true,
                        ),

                        const SizedBox(height: 40),

                        // SUMBER LINK
                        if (article['source_link'] != null &&
                            article['source_link'].toString().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.link, color: Colors.blue),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Sumber Referensi:",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        article['source_link'],
                                        style: GoogleFonts.poppins(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          decoration: TextDecoration.underline,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 50), // Ruang bawah
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
