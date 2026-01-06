import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Add carousel_slider to pubspec.yaml
import '../services/api_service.dart';

class HomeWayangPage extends StatefulWidget {
  const HomeWayangPage({super.key});

  @override
  State<HomeWayangPage> createState() => _HomeWayangPageState();
}

class _HomeWayangPageState extends State<HomeWayangPage> with SingleTickerProviderStateMixin {
  String namaUser = "Sobat Wayang";
  
  // Animation for Chatbot
  late AnimationController _botAnimController;
  late Animation<double> _botScaleAnim;

  // Banner Images
  final List<String> imgList = [
    'assets/banner.jpg', // Placeholder
    'assets/MencariDalang.jpeg', // Placeholder
    'assets/banner1.png', // Placeholder
    'assets/PertunjukanWayang.jpeg', // Placeholder
  ];

  // Dummy Artikel
  final List<Map<String, String>> articles = [
    {
      "title": "Filosofi Semar dalam Kehidupan Modern",
      "image": "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Semar_Wayang.jpg/220px-Semar_Wayang.jpg",
      "desc": "Belajar kebijaksanaan dari tokoh punakawan tertua yang rendah hati."
    },
    {
      "title": "Asal Usul Wayang Golek Sunda",
      "image": "https://upload.wikimedia.org/wikipedia/commons/e/e0/Wayang_Golek_Cepot.jpg",
      "desc": "Sejarah panjang kesenian kayu yang mendunia dari tanah Pasundan."
    },
    {
      "title": "Pandawa Lima: Simbol Kebajikan",
      "image": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Wayang_Pandawa.jpg/300px-Wayang_Pandawa.jpg",
      "desc": "Mengenal 5 ksatria penegak kebenaran dalam epos Mahabharata."
    },
    {
      "title": "Teknologi AI untuk Pelestarian Budaya",
      "image": "https://cdn.pixabay.com/photo/2018/05/08/08/44/artificial-intelligence-3382507_1280.jpg",
      "desc": "Bagaimana Wayanusa membantu generasi muda mengenal wayang kembali."
    },
  ];

  @override
  void initState() {
    super.initState();
    loadUser();
    
    // Animasi Chatbot (Bernafas)
    _botAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _botScaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _botAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _botAnimController.dispose();
    super.dispose();
  }

  void loadUser() async {
    final profile = await ApiService.getProfile();
    if (mounted && profile != null) {
      setState(() {
        namaUser = profile['name']?.split(" ")[0] ?? "Sobat"; // Ambil nama depan
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Palet Warna Modern
    const primaryColor = Color(0xFFD4A373);
    const bgColor = Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), // Ruang untuk chatbot
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HEADER & GREETING
                  _buildHeader(context),

                  const SizedBox(height: 20),

                  // 2. BANNER CAROUSEL
                  _buildCarousel(),

                  const SizedBox(height: 30),

                  // 3. MENU UTAMA (GRID)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Jelajahi Wayang",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        fontFamily: 'Serif',
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildMenuGrid(context),

                  const SizedBox(height: 35),

                  // 4. ARTIKEL TERBARU
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Wawasan Budaya",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            fontFamily: 'Serif',
                          ),
                        ),
                        Text(
                          "Lihat Semua",
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // List Artikel
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      return _buildArticleCard(articles[index]);
                    },
                  ),
                ],
              ),
            ),
            
            // 5. FLOATING CHATBOT
            Positioned(
              bottom: 25,
              right: 20,
              child: ScaleTransition(
                scale: _botScaleAnim,
                child: FloatingActionButton.extended(
                  onPressed: () => Navigator.pushNamed(context, '/chatbot'),
                  backgroundColor: const Color(0xFF4B3425),
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                  label: const Text("Tanya ChatPot", style: TextStyle(color: Colors.white)),
                  elevation: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: Header
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selamat Datang, 👋",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                namaUser,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4B3425),
                  fontFamily: 'Serif',
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD4A373), width: 2),
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage("https://cdn-icons-png.flaticon.com/512/3135/3135715.png"),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Carousel
  Widget _buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180.0,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        aspectRatio: 16/9,
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
      items: imgList.map((item) {
        return Container(
          width: 1000,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: NetworkImage(item),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.all(20),
            alignment: Alignment.bottomLeft,
            child: const Text(
              "Jelajahi Dunia Wayang",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // WIDGET: Menu Grid
  Widget _buildMenuGrid(BuildContext context) {
    // List Menu
    final menus = [
      {"icon": Icons.precision_manufacturing_rounded, "label": "Smart Wayang", "route": "/smart_wayang", "color": Colors.teal},
      {"icon": Icons.camera_alt_rounded, "label": "Scan Wayang", "route": "/pengenalan_wayang", "color": Colors.orange},
      {"icon": Icons.people_alt_rounded, "label": "Cari Dalang", "route": "/cari_dalang", "color": Colors.purple},
      {"icon": Icons.quiz_rounded, "label": "Kuis Seru", "route": "/tes_singkat", "color": Colors.blue},
      {"icon": Icons.video_library_rounded, "label": "Video Wayang", "route": "/video", "color": Colors.red},
      {"icon": Icons.video_library_rounded, "label": "Dalang Virtual", "route": "/", "color": Colors.red},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 Kolom agar besar
          childAspectRatio: 2.5, // Lebar : Tinggi
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: menus.length,
        itemBuilder: (context, index) {
          final menu = menus[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, menu['route'] as String);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (menu['color'] as Color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(menu['icon'] as IconData, color: menu['color'] as Color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      menu['label'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // WIDGET: Article Card
  Widget _buildArticleCard(Map<String, String> article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          // Gambar Artikel
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              article['image']!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100, height: 100, color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          
          // Teks Artikel
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF4B3425),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article['desc']!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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