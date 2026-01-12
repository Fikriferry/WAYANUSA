import 'package:flutter/material.dart';
import '../services/dalang_api.dart'; // Import ApiService yang baru
import 'detail_dalang_page.dart'; // Pastikan file ini ada
import '../config.dart';

class CariDalangPage extends StatefulWidget {
  const CariDalangPage({super.key});

  @override
  State<CariDalangPage> createState() => _CariDalangPageState();
}

class _CariDalangPageState extends State<CariDalangPage> {
  final TextEditingController _searchController = TextEditingController();
  
  // Kita gunakan List<Map> agar fleksibel sesuai return ApiService
  List<Map<String, dynamic>> _allDalang = [];
  List<Map<String, dynamic>> _filteredDalang = [];
  
  bool _loading = true;

  // URL Base untuk gambar (Sesuaikan dengan IP Flask kamu)
  // Folder static flask biasanya diakses via /static/...
  final String imageBaseUrl = AppConfig.dalangImageUrl;

  @override
  void initState() {
    super.initState();
    _loadDalang();
  }

  // --- LOAD DATA DARI API SERVICE ---
  Future<void> _loadDalang() async {
    setState(() => _loading = true);
    try {
      // Panggil fungsi getDalang dari ApiService yang baru
      final data = await DalangApi.getDalang();
      
      setState(() {
        _allDalang = data;
        _filteredDalang = data; // Awalnya tampilkan semua
      });
    } catch (e) {
      debugPrint("Error loading dalang: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  // --- LOGIC PENCARIAN ---
  void _runFilter(String keyword) {
    List<Map<String, dynamic>> results = [];
    if (keyword.isEmpty) {
      results = _allDalang;
    } else {
      results = _allDalang
          .where((user) =>
              user["nama"].toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredDalang = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Palet Warna Wayanusa
    const primaryColor = Color(0xFFD4A373);
    const bgColor = Color(0xFFFDFBF7);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4B3425)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Cari Dalang",
          style: TextStyle(
            color: Color(0xFF4B3425),
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif', // Sentuhan klasik
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // 1. SEARCH BAR MODERN
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _runFilter,
                decoration: InputDecoration(
                  hintText: "Cari nama dalang...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search_rounded, color: primaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            
            const SizedBox(height: 25),

            // 2. LIST DATA
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: primaryColor))
                  : _filteredDalang.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: _filteredDalang.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final dalang = _filteredDalang[index];
                            return _buildDalangCard(dalang);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: Kartu Dalang
  Widget _buildDalangCard(Map<String, dynamic> dalang) {
    // Konstruksi URL Gambar Lengkap
    // Jika nama file ada, gabung dengan base URL. Jika tidak, kosong.
    String fotoName = dalang['foto'] ?? "";
    String fullImageUrl = fotoName.isNotEmpty ? "$imageBaseUrl/$fotoName" : "";

    return GestureDetector(
      onTap: () {
        // Navigasi ke Detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailDalangPage(
              nama: dalang['nama'] ?? "Tanpa Nama",
              alamat: dalang['alamat'] ?? "-",
              detailAlamat: dalang['alamat'], // Sesuaikan jika ada field detail
              gambar: fullImageUrl, // Kirim URL lengkap
              latitude: dalang['latitude'] ?? 0.0,
              longitude: dalang['longitude'] ?? 0.0,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A373).withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // FOTO PROFIL
            Hero(
              tag: "avatar_${dalang['id']}",
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD4A373), width: 2),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: (fullImageUrl.isNotEmpty)
                        ? NetworkImage(fullImageUrl)
                        : const NetworkImage("https://cdn-icons-png.flaticon.com/512/3135/3135715.png") as ImageProvider,
                    onError: (exception, stackTrace) {
                      // Handle jika gambar error load
                      debugPrint("Gagal load gambar: $fullImageUrl");
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // INFO TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dalang['nama'] ?? "Tanpa Nama",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B3425),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          dalang['alamat'] ?? "Alamat tidak tersedia",
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // ARROW ICON
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFD4A373)),
          ],
        ),
      ),
    );
  }

  // WIDGET: Jika Data Kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            "Dalang tidak ditemukan",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}