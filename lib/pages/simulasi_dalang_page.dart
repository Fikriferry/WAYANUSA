import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Wajib install ini di pubspec.yaml
import '../models/wayang_game.dart';
import '../services/api_service.dart';
import '../services/image_helper.dart';

// ===============================================================
// 1. CONTROLLER (Penyimpan Data & Posisi yang Ringan)
// ===============================================================
class WayangController {
  final int id;
  final String nama;
  final String? badanUrl;
  final String? tgnKananAtas;
  final String? tgnKananBawah;
  final String? tgnKiriAtas;
  final String? tgnKiriBawah;

  // State Posisi (Notifier) - Biar gak perlu SetState satu layar
  final ValueNotifier<Offset> position;
  final ValueNotifier<double> rotKiriAtas = ValueNotifier(0.5);
  final ValueNotifier<double> rotKiriBawah = ValueNotifier(0.8);
  final ValueNotifier<double> rotKananAtas = ValueNotifier(0.4);
  final ValueNotifier<double> rotKananBawah = ValueNotifier(0.3);

  WayangController({
    required this.id,
    required this.nama,
    this.badanUrl,
    this.tgnKananAtas, this.tgnKananBawah,
    this.tgnKiriAtas, this.tgnKiriBawah,
    required Offset startPos,
  }) : position = ValueNotifier(startPos);
  
  void dispose() {
    position.dispose();
    rotKiriAtas.dispose();
    rotKiriBawah.dispose();
    rotKananAtas.dispose();
    rotKananBawah.dispose();
  }
}

// ===============================================================
// 2. HALAMAN UTAMA (LOGIKA GAME)
// ===============================================================
class SimulasiDalangPage extends StatefulWidget {
  const SimulasiDalangPage({super.key});

  @override
  State<SimulasiDalangPage> createState() => _SimulasiDalangPageState();
}

class _SimulasiDalangPageState extends State<SimulasiDalangPage> {
  final List<WayangController> activeWayang = [];
  List<WayangGame> libraryWayang = [];
  bool isLoading = true;
  bool isOverDeleteZone = false;
  final double deleteZoneSize = 70;

  @override
  void initState() {
    super.initState();
    _loadData();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    for (var w in activeWayang) w.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, 
      DeviceOrientation.portraitDown
    ]);
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final data = await ApiService.getWayangGameList();
      if(mounted) setState(() { libraryWayang = data; isLoading = false; });
    } catch (_) {
      if(mounted) setState(() => isLoading = false);
    }
  }

  void _bringToFront(int index) {
    if (index == activeWayang.length - 1) return;
    setState(() {
      final item = activeWayang.removeAt(index);
      activeWayang.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Skala responsif (HP Kecil vs Tablet)
    final scaleFactor = size.height / 400.0; 

    return Scaffold(
      backgroundColor: const Color(0xffFEFBF5), // Warna background original
      body: Stack(
        children: [
          // LAYER 1: BACKGROUND PANGGUNG
          Positioned.fill(
            child: Image.asset(
              "assets/background_panggung.png",
              fit: BoxFit.cover,
              errorBuilder: (_,__,___) => Container(color: Colors.brown),
            ),
          ),

          // LAYER 2: WAYANG (Dirender ulang hanya saat bergerak)
          ...activeWayang.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;

            return ValueListenableBuilder<Offset>(
              valueListenable: controller.position,
              builder: (context, pos, child) {
                return Positioned(
                  left: pos.dx,
                  top: pos.dy,
                  child: GestureDetector(
                    onPanStart: (_) => _bringToFront(index),
                    onPanUpdate: (d) {
                      controller.position.value += d.delta; 
                      
                      // Cek Delete Zone
                      final zoneY = size.height - deleteZoneSize;
                      final isInZone = pos.dx < deleteZoneSize && pos.dy > zoneY;
                      if (isOverDeleteZone != isInZone) {
                        setState(() => isOverDeleteZone = isInZone);
                      }
                    },
                    onPanEnd: (_) {
                      if (isOverDeleteZone) {
                        setState(() {
                          controller.dispose();
                          activeWayang.removeAt(index);
                          isOverDeleteZone = false;
                        });
                      }
                    },
                    // RepaintBoundary: Isolasi render wayang biar smooth
                    child: RepaintBoundary(
                      child: Transform.scale(
                        scale: scaleFactor, // Responsif size
                        alignment: Alignment.topLeft,
                        child: WayangActor(ctrl: controller),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // LAYER 3: UI DELETE ZONE
          Positioned(
            left: 20, bottom: 20,
            child: AnimatedScale(
              scale: isOverDeleteZone ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: CircleAvatar(
                radius: deleteZoneSize / 2,
                backgroundColor: isOverDeleteZone ? Colors.red : Colors.red.withOpacity(0.4),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
            ),
          ),

          // LAYER 4: TOMBOL TAMBAH
          Positioned(
            right: 20, bottom: 20,
            child: ElevatedButton.icon(
              onPressed: () => _showPicker(context),
              icon: const Icon(Icons.theater_comedy),
              label: const Text("Tambah Wayang"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffF3E7D3),
                foregroundColor: Colors.brown,
              ),
            ),
          ),
          
          // LAYER 5: TOMBOL BACK
          Positioned(
             top: 20, left: 20,
             child: CircleAvatar(
               backgroundColor: Colors.white54,
               child: IconButton(
                 icon: const Icon(Icons.arrow_back, color: Colors.black),
                 onPressed: () => Navigator.pop(context),
               ),
             ),
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: 180,
        decoration: const BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
        ),
        child: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(15),
              itemCount: libraryWayang.length,
              itemBuilder: (_, i) {
                final w = libraryWayang[i];
                return GestureDetector(
                  onTap: () {
                    // Posisi awal muncul di tengah layar
                    final startPos = Offset(MediaQuery.of(context).size.width/2 - 130, 100);
                    setState(() {
                      activeWayang.add(WayangController(
                        id: w.id, nama: w.nama,
                        badanUrl: w.badan != null ? ImageHelper.resolve(w.badan!) : null,
                        tgnKananAtas: w.tanganKananAtas != null ? ImageHelper.resolve(w.tanganKananAtas!) : null,
                        tgnKananBawah: w.tanganKananBawah != null ? ImageHelper.resolve(w.tanganKananBawah!) : null,
                        tgnKiriAtas: w.tanganKiriAtas != null ? ImageHelper.resolve(w.tanganKiriAtas!) : null,
                        tgnKiriBawah: w.tanganKiriBawah != null ? ImageHelper.resolve(w.tanganKiriBawah!) : null,
                        startPos: startPos,
                      ));
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 100, margin: const EdgeInsets.only(right: 10),
                    child: Column(
                      children: [
                        Expanded(
                          child: CachedNetworkImage(
                            imageUrl: ImageHelper.resolve(w.thumbnail ?? ''), 
                            errorWidget: (_,__,___)=>const Icon(Icons.broken_image)
                          )
                        ),
                        Text(w.nama, maxLines: 1, overflow: TextOverflow.ellipsis)
                      ],
                    ),
                  ),
                );
              },
            ),
      )
    );
  }
}

// ===============================================================
// 3. WIDGET RIGGING (KOORDINAT DIKEMBALIKAN KE KODE ASLI)
// ===============================================================
class WayangActor extends StatelessWidget {
  final WayangController ctrl;
  const WayangActor({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    // 🔥 KOORDINAT ASLI DARI KODE ANDA
    const double badanLeft = 90;
    const double badanTop = 40;

    return SizedBox(
      width: 260, height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // === BADAN ===
          if (ctrl.badanUrl != null)
             Positioned(
               left: badanLeft, 
               top: badanTop, 
               child: CachedNetworkImage(imageUrl: ctrl.badanUrl!, height: 260)
             ),
          
          // === LENGAN KIRI (Belakang) ===
          if (ctrl.tgnKiriAtas != null)
            _Limb(
              url: ctrl.tgnKiriAtas,
              angleNotifier: ctrl.rotKiriAtas,
              // Koordinat Asli: left: badanLeft + 20, top: badanTop + 70
              left: badanLeft + 20, 
              top: badanTop + 70, 
              // Pivot Asli: 25, 5
              pivotX: 25.0, pivotY: 5.0,
              
              child: ctrl.tgnKiriBawah != null ? _Limb(
                url: ctrl.tgnKiriBawah,
                angleNotifier: ctrl.rotKiriBawah,
                // Koordinat Asli: left: -35, top: 97
                left: -35, top: 97, 
                // Pivot Asli: 52, 5
                pivotX: 52.0, pivotY: 5.0,
                hasStick: true, inverse: false,
              ) : null,
            ),

          // === LENGAN KANAN (Depan) ===
          if (ctrl.tgnKananAtas != null)
            _Limb(
              url: ctrl.tgnKananAtas,
              angleNotifier: ctrl.rotKananAtas,
              // Koordinat Asli: left: badanLeft + 150, top: badanTop + 45
              left: badanLeft + 150, 
              top: badanTop + 45, 
              // Pivot Asli: 10, 10
              pivotX: 10.0, pivotY: 10.0,
              inverse: true, // Gerakan dibalik
              
              child: ctrl.tgnKananBawah != null ? _Limb(
                url: ctrl.tgnKananBawah,
                angleNotifier: ctrl.rotKananBawah,
                // Koordinat Asli: left: 30, top: 65
                left: 30, top: 65, 
                // Pivot Asli: 93, 12
                pivotX: 93.0, pivotY: 12.0,
                hasStick: true, inverse: true, // Gerakan dibalik
              ) : null,
            ),
        ],
      ),
    );
  }
}

// ===============================================================
// 4. LIMB CONTROL (LOGIKA ROTASI)
// ===============================================================
class _Limb extends StatelessWidget {
  final String? url;
  final ValueNotifier<double> angleNotifier;
  final double left, top, pivotX, pivotY;
  final Widget? child;
  final bool hasStick, inverse;

  const _Limb({
    required this.url, required this.angleNotifier,
    required this.left, required this.top,
    required this.pivotX, required this.pivotY,
    this.child, this.hasStick = false, this.inverse = false,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null) return const SizedBox();

    return ValueListenableBuilder<double>(
      valueListenable: angleNotifier,
      builder: (context, angle, _) {
        return Positioned(
          left: left, top: top,
          child: Transform(
            transform: Matrix4.identity()
              ..translate(pivotX, pivotY) // Titik putar
              ..rotateZ(angle)
              ..translate(-pivotX, -pivotY), // Kembalikan posisi
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CachedNetworkImage(imageUrl: url!, height: (hasStick && inverse) ? 80 : (inverse ? 85 : 100)), // Tinggi disesuaikan dg kode asli
                
                if (child != null) child!,
                
                // Stick Transparan untuk Area Sentuh
                if (hasStick) _StickHandle(
                  inverse: inverse, 
                  onDrag: (dy) {
                    // Logika Rotasi: dy adalah perubahan vertikal
                    final diff = inverse ? -dy : dy; 
                    angleNotifier.value = (angle + diff * 0.02).clamp(-1.6, 1.6);
                  }
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StickHandle extends StatelessWidget {
  final bool inverse;
  final Function(double) onDrag;
  const _StickHandle({required this.inverse, required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // Stick menjulur ke bawah untuk pegangan
      bottom: -40,
      left: inverse ? 10 : null, right: inverse ? null : 10,
      child: GestureDetector(
        onPanUpdate: (d) => onDrag(d.delta.dy),
        child: Container(
          width: 50, height: 100, // Hitbox besar biar gampang kesentuh
          color: Colors.transparent, // Transparan agar tidak menutupi gambar
          // Debugging: Ganti warna transparent jadi Colors.red.withOpacity(0.3) kalau mau lihat area sentuh
        ),
      ),
    );
  }
}