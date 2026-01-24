import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../models/wayang_game.dart';
import '../services/api_service.dart';
import '../services/image_helper.dart';

// ===============================================================
// 1. CONTROLLER (State Management & Data)
// ===============================================================
class WayangController {
  final int id;
  final String nama;

  // URL Gambar
  final String? badanUrl;
  final String? tgnKananAtas;
  final String? tgnKananBawah;
  final String? tgnKiriAtas;
  final String? tgnKiriBawah;

  // Koordinat Siku Spesifik (Dari Code Baru)
  final Offset sikuKiriOffset; // Ex: -35.0, 95.0
  final Offset sikuKananOffset; // Ex: -05.0, 25.0

  // State Posisi Utama (Drag Badan)
  final ValueNotifier<Offset> position;

  // State Sudut (Notifier agar performa tinggi tanpa setState layar penuh)
  final ValueNotifier<double> angleKiriAtas;
  final ValueNotifier<double> angleKiriBawahRel; // Sudut Relatif
  final ValueNotifier<double> angleKananAtas;
  final ValueNotifier<double> angleKananBawahRel; // Sudut Relatif

  WayangController({
    required this.id,
    required this.nama,
    this.badanUrl,
    this.tgnKananAtas,
    this.tgnKananBawah,
    this.tgnKiriAtas,
    this.tgnKiriBawah,
    required Offset startPos,
    // Default value offset siku jika null
    this.sikuKiriOffset = const Offset(
      -35.0,
      95.0,
    ), // X: Geser Kiri (-) atau Kanan (+)
    this.sikuKananOffset = const Offset(
      77.0,
      80.0,
    ), // Y: Geser Atas (makin kecil) atau Bawah (makin besar)
    double startAngleKiri = 0.5,
    double startAngleKanan = -0.5,
  }) : position = ValueNotifier(startPos),
       angleKiriAtas = ValueNotifier(startAngleKiri),
       angleKiriBawahRel = ValueNotifier(0.4),
       angleKananAtas = ValueNotifier(startAngleKanan),
       angleKananBawahRel = ValueNotifier(-0.4);

  void dispose() {
    position.dispose();
    angleKiriAtas.dispose();
    angleKiriBawahRel.dispose();
    angleKananAtas.dispose();
    angleKananBawahRel.dispose();
  }
}

// ===============================================================
// 2. PAGE UTAMA (Hanya Mengurus Logic Game)
// ===============================================================
class SimulasiDalangPage extends StatefulWidget {
  const SimulasiDalangPage({super.key});

  @override
  State<SimulasiDalangPage> createState() => _SimulasiDalangPageState();
}

class _SimulasiDalangPageState extends State<SimulasiDalangPage> {
  final List<WayangController> activeWayang =
      []; // List Controller, bukan Map lagi
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
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final data =
          await ApiService.getWayangGameList(); // Sesuaikan nama fungsi API Anda
      if (mounted)
        setState(() {
          libraryWayang = data;
          isLoading = false;
        });
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Fungsi: Bawa wayang yang disentuh ke layer paling depan
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

    return Scaffold(
      backgroundColor: const Color(0xffFEFBF5),
      body: Stack(
        children: [
          // BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/background_panggung.png",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xffFEFBF5)),
            ),
          ),

          // WAYANG LIST (Looping Controller)
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
                      // Update Posisi
                      controller.position.value += d.delta;

                      // Cek Delete Zone
                      final zoneY = size.height - deleteZoneSize;
                      final isInZone =
                          pos.dx < deleteZoneSize && (pos.dy + 120) > zoneY;
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
                    // MENGGUNAKAN CLASS WAYANG ACTOR (Code Lama tapi Logic Baru)
                    child: WayangActor(ctrl: controller),
                  ),
                );
              },
            );
          }),

          // TOMBOL & UI LAINNYA
          _buildDeleteZone(),
          _buildAddButton(context),
          _buildBackButton(context),
        ],
      ),
    );
  }

  // --- UI COMPONENTS (Biar Rapi) ---
  Widget _buildDeleteZone() {
    return Positioned(
      left: 20,
      bottom: 20,
      child: AnimatedScale(
        scale: isOverDeleteZone ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: CircleAvatar(
          radius: deleteZoneSize / 2,
          backgroundColor: isOverDeleteZone
              ? Colors.red
              : Colors.red.withOpacity(0.4),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 20,
      child: ElevatedButton.icon(
        onPressed: () => _showPicker(context),
        icon: const Icon(Icons.theater_comedy),
        label: const Text("Tambah Wayang"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffF3E7D3),
          foregroundColor: Colors.brown,
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      child: CircleAvatar(
        backgroundColor: Colors.white54,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: 180,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                      final startPos = Offset(
                        MediaQuery.of(context).size.width / 2 - 130,
                        100,
                      );
                      setState(() {
                        activeWayang.add(
                          WayangController(
                            id: w.id,
                            nama: w.nama,
                            badanUrl: w.badan != null
                                ? ImageHelper.resolve(w.badan!)
                                : null,
                            tgnKananAtas: w.tanganKananAtas != null
                                ? ImageHelper.resolve(w.tanganKananAtas!)
                                : null,
                            tgnKananBawah: w.tanganKananBawah != null
                                ? ImageHelper.resolve(w.tanganKananBawah!)
                                : null,
                            tgnKiriAtas: w.tanganKiriAtas != null
                                ? ImageHelper.resolve(w.tanganKiriAtas!)
                                : null,
                            tgnKiriBawah: w.tanganKiriBawah != null
                                ? ImageHelper.resolve(w.tanganKiriBawah!)
                                : null,
                            startPos: startPos,
                            // Anda bisa menambahkan data offset siku dari API jika ada fieldnya
                          ),
                        );
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(
                              ImageHelper.resolve(w.thumbnail ?? ''),
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ),
                          Text(
                            w.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// ===============================================================
// 3. WAYANG ACTOR (Ini adalah _WayangStack yang dipindah ke atas)
// ===============================================================
class WayangActor extends StatelessWidget {
  final WayangController ctrl;

  const WayangActor({super.key, required this.ctrl});

  // Helper Matematika Rotasi (Dari Code B)
  Offset _rotateOffset(Offset original, double angle) {
    final cosA = cos(angle);
    final sinA = sin(angle);
    final x = original.dx * cosA - original.dy * sinA;
    final y = original.dx * sinA + original.dy * cosA;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    const double badanLeft = 90;
    const double badanTop = 40;

    // --- LOGIKA POSISI SIKU (Dari Code B) ---
    // Posisi Bahu relatif terhadap badan
    final Offset bahuKiri = const Offset(badanLeft + 20, badanTop + 70);
    final Offset bahuKanan = const Offset(badanLeft + 150, badanTop + 45);

    return SizedBox(
      width: 420,
      height: 420,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. BADAN
          if (ctrl.badanUrl != null)
            Positioned(
              left: badanLeft,
              top: badanTop,
              child: Image.network(ctrl.badanUrl!, height: 260),
            ),

          // 2. LENGAN KIRI (Belakang Badan)
          // Kita butuh ValueListenableBuilder untuk update real-time tanpa redraw seluruh widget
          if (ctrl.tgnKiriAtas != null)
            ValueListenableBuilder<double>(
              valueListenable: ctrl.angleKiriAtas,
              builder: (ctx, angleAtas, _) {
                // Hitung posisi siku Kiri secara dinamis berdasarkan sudut bahu
                final Offset rotatedSiku = _rotateOffset(
                  Offset(0, ctrl.sikuKiriOffset.dy),
                  angleAtas,
                );
                final Offset sikuKiriPos =
                    bahuKiri + rotatedSiku + Offset(ctrl.sikuKiriOffset.dx, 0);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Lengan Atas Kiri
                    _RotatedLimb(
                      left: bahuKiri.dx,
                      top: bahuKiri.dy,
                      pivotX: 25,
                      pivotY: 5,
                      angle: angleAtas,
                      height: 110,
                      imageUrl: ctrl.tgnKiriAtas!,
                      onAngleChange: (v) => ctrl.angleKiriAtas.value = v,
                      minAngle: -1.2,
                      maxAngle: 0.4,
                      sensitivity: 0.015,
                    ),

                    // Lengan Bawah Kiri (Menempel di Siku yang bergerak)
                    if (ctrl.tgnKiriBawah != null)
                      ValueListenableBuilder<double>(
                        valueListenable: ctrl.angleKiriBawahRel,
                        builder: (ctx, angleRel, _) {
                          return _RotatedLimb(
                            left: sikuKiriPos.dx,
                            top: sikuKiriPos.dy,
                            pivotX: 55,
                            pivotY: 5,
                            angle: angleAtas + angleRel, // Sudut Absolut
                            height: 100,
                            imageUrl: ctrl.tgnKiriBawah!,
                            // Logic update sudut relatif
                            onAngleChange: (v) {
                              ctrl.angleKiriBawahRel.value = (v - angleAtas)
                                  .clamp(-1.2, 1.2);
                            },
                            minAngle: -1.2,
                            maxAngle: 1.2,
                            sensitivity: 0.02,
                            // Debug color: Colors.blue
                          );
                        },
                      ),
                  ],
                );
              },
            ),

          // 3. LENGAN KANAN (Depan Badan)
          if (ctrl.tgnKananAtas != null)
            ValueListenableBuilder<double>(
              valueListenable: ctrl.angleKananAtas,
              builder: (ctx, angleAtas, _) {
                // Hitung posisi siku Kanan dinamis
                final Offset rotatedSiku = _rotateOffset(
                  ctrl.sikuKananOffset,
                  angleAtas,
                );
                final Offset sikuKananPos = bahuKanan + rotatedSiku;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Lengan Atas Kanan
                    _RotatedLimb(
                      left: bahuKanan.dx,
                      top: bahuKanan.dy,
                      pivotX: 10,
                      pivotY: 10,
                      angle: angleAtas,
                      height: 85,
                      imageUrl: ctrl.tgnKananAtas!,
                      invertDrag:
                          true, // Gerakan mouse terbalik utk tangan kanan
                      onAngleChange: (v) => ctrl.angleKananAtas.value = v,
                      minAngle: -0.4,
                      maxAngle: 1.2,
                      sensitivity: 0.015,
                    ),

                    // Lengan Bawah Kanan
                    if (ctrl.tgnKananBawah != null)
                      ValueListenableBuilder<double>(
                        valueListenable: ctrl.angleKananBawahRel,
                        builder: (ctx, angleRel, _) {
                          // KUNCI PERBAIKAN:
                          // Karena Engsel (Gelang) ada di KIRI gambar, pX harus KECIL.
                          // Kalau pX = 100, dia akan muter di tangan (salah).
                          final double pX = 100.0;
                          final double pY = 10.0;

                          return _RotatedLimb(
                            // Rumus: Tempelkan titik pX, pY gambar ke Siku
                            left: sikuKananPos.dx - pX,
                            top: sikuKananPos.dy - pY,

                            pivotX:
                                pX, // Titik putar di gelang (18px dari kiri)
                            pivotY: pY,

                            angle: angleAtas + angleRel,
                            height: 80,
                            imageUrl: ctrl.tgnKananBawah!,
                            invertDrag: true,
                            onAngleChange: (v) {
                              ctrl.angleKananBawahRel.value = (v - angleAtas)
                                  .clamp(-1.2, 1.2);
                            },
                          );
                        },
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

// ===============================================================
// 4. LIMB WIDGET (Widget Lengan yang bisa diputar)
// ===============================================================
class _RotatedLimb extends StatefulWidget {
  final double left, top, pivotX, pivotY, angle, height;
  final String imageUrl;
  final double sensitivity, minAngle, maxAngle;
  final bool invertDrag;
  final Function(double) onAngleChange;

  const _RotatedLimb({
    required this.left,
    required this.top,
    required this.pivotX,
    required this.pivotY,
    required this.angle,
    required this.height,
    required this.imageUrl,
    required this.onAngleChange,
    this.sensitivity = 0.01,
    this.minAngle = -2.0,
    this.maxAngle = 2.0,
    this.invertDrag = false,
  });

  @override
  State<_RotatedLimb> createState() => _RotatedLimbState();
}

class _RotatedLimbState extends State<_RotatedLimb> {
  double _startDy = 0;
  double _startAngle = 0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: Transform(
        transformHitTests: true,
        transform: Matrix4.identity()
          ..translate(widget.pivotX, widget.pivotY)
          ..rotateZ(widget.angle)
          ..translate(-widget.pivotX, -widget.pivotY),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (d) {
            _startDy = d.globalPosition.dy;
            _startAngle = widget.angle;
          },
          onPanUpdate: (d) {
            final diff = widget.invertDrag
                ? _startDy - d.globalPosition.dy
                : d.globalPosition.dy - _startDy;

            final next = (_startAngle + diff * widget.sensitivity).clamp(
              widget.minAngle,
              widget.maxAngle,
            );

            widget.onAngleChange(next);
          },
          child: Image.network(widget.imageUrl, height: widget.height),
        ),
      ),
    );
  }
}
