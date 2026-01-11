import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimulasiDalangPage extends StatefulWidget {
  const SimulasiDalangPage({super.key});

  @override
  State<SimulasiDalangPage> createState() => _SimulasiDalangPageState();
}

class _SimulasiDalangPageState extends State<SimulasiDalangPage> {
  final List<Map<String, dynamic>> activeWayang = [];
  final double deleteZoneSize = 50.0;

  final List<Map<String, String>> wayangList = [
    {"name": "Arjuna", "image": "assets/wayang_arjuna.png"},
    {"name": "Bima", "image": "assets/wayang_bima.png"},
    {"name": "Semar", "image": "assets/wayang_semar.png"},
    {"name": "Srikandi", "image": "assets/wayang_srikandi.png"},
  ];

  bool isOverDeleteZone = false;

  // Force landscape di mobile
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape || screenWidth > screenHeight;

    return Scaffold(
      backgroundColor: const Color(0xffFEFBF5),
      appBar: AppBar(
        title: const Text(
          "Simulasi Dalang",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff4B3425),
          ),
        ),
        backgroundColor: const Color(0xffF3E7D3),
        iconTheme: const IconThemeData(color: Color(0xff4B3425)),
      ),
      body: Stack(
        children: [
          // BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/background_panggung.png",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xffE8D4BE)),
            ),
          ),

          // WAYANG AKTIF
          ...activeWayang.map((wayang) {
            int index = activeWayang.indexOf(wayang);
            return Positioned(
              left: wayang['position'].dx,
              top: wayang['position'].dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    wayang['position'] += details.delta;

                    final double centerY = wayang['position'].dy + 120;
                    if (wayang['position'].dx < deleteZoneSize &&
                        centerY > screenHeight - deleteZoneSize - 20) {
                      isOverDeleteZone = true;
                    } else {
                      isOverDeleteZone = false;
                    }
                  });
                },
                onPanEnd: (_) {
                  if (isOverDeleteZone) {
                    setState(() {
                      activeWayang.removeAt(index);
                      isOverDeleteZone = false;
                    });
                  }
                },
                child: AnimatedOpacity(
                  opacity: isOverDeleteZone ? 0.6 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Image.asset(
                    wayang['image'],
                    height: 180,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported, size: 120, color: Colors.grey),
                  ),
                ),
              ),
            );
          }).toList(),

          // CONTROL BOTTOM
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: deleteZoneSize,
                  width: deleteZoneSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOverDeleteZone
                        ? Colors.red.withOpacity(0.8)
                        : Colors.red.withOpacity(0.4),
                    boxShadow: [
                      if (isOverDeleteZone)
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 4,
                        ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: isOverDeleteZone ? 46 : 38,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffE8D4BE),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => _showWayangPicker(context),
                  icon: const Icon(Icons.theater_comedy, color: Color(0xff4B3425)),
                  label: const Text(
                    "Tambah Wayang",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff4B3425)),
                  ),
                ),
              ],
            ),
          ),

          // OVERLAY CEK LANDSCAPE (khusus web)
          if (!isLandscape)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: Text(
                    "⚠️ Silakan rotate device ke landscape",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showWayangPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xffFEFBF5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pilih Wayang untuk Dimainkan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff4B3425),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: wayangList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, index) {
                    final wayang = wayangList[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          activeWayang.add({
                            'image': wayang['image'],
                            'position': const Offset(150, 200),
                          });
                        });
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              color: const Color(0xffF3E7D3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xff4B3425)),
                            ),
                            child: Image.asset(
                              wayang["image"]!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            wayang["name"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xff4B3425),
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
        );
      },
    );
  }
}