import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wayang_game.dart';
import '../services/api_service.dart';
import '../services/image_helper.dart';

class SimulasiDalangPage extends StatefulWidget {
  const SimulasiDalangPage({super.key});

  @override
  State<SimulasiDalangPage> createState() => _SimulasiDalangPageState();
}

class _SimulasiDalangPageState extends State<SimulasiDalangPage> {
  double _startDy = 0;
  double _startAngle = 0;
  final List<Map<String, dynamic>> activeWayang = [];
  final double deleteZoneSize = 50;

  List<WayangGame> wayangList = [];
  bool isLoading = true;
  bool isOverDeleteZone = false;

  @override
  void initState() {
    super.initState();
    _loadWayang();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _loadWayang() async {
    try {
      final data = await ApiService.getWayangGame();
      setState(() {
        wayangList = data;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isLandscape = screen.width > screen.height;

    return Scaffold(
      backgroundColor: const Color(0xffFEFBF5),
      appBar: AppBar(
        title: const Text(
          "Simulasi Dalang",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xffF3E7D3),
      ),
      body: Stack(
        children: [
          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/background_panggung.png",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          /// WAYANG AKTIF
          ...activeWayang.map((w) {
            final index = activeWayang.indexOf(w);
            return Positioned(
              left: w['position'].dx,
              top: w['position'].dy,
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild, // 🔥 INI KUNCI
                onPanUpdate: (d) {
                  setState(() {
                    w['position'] += d.delta;

                    final centerY = w['position'].dy + 120;
                    isOverDeleteZone =
                        w['position'].dx < deleteZoneSize &&
                        centerY > screen.height - deleteZoneSize;
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
                child: _WayangStack(w),
              ),
            );
          }),

          /// BOTTOM CONTROL
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: deleteZoneSize / 2,
                  backgroundColor: isOverDeleteZone
                      ? Colors.red
                      : Colors.red.withOpacity(.4),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showWayangPicker(context),
                  icon: const Icon(Icons.theater_comedy),
                  label: const Text("Tambah Wayang"),
                ),
              ],
            ),
          ),

          /// OVERLAY JIKA PORTRAIT
          if (!isLandscape)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: Text(
                    "Rotate ke landscape",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ===== WIDGET WAYANG =====
  Widget _WayangStack(Map<String, dynamic> w) {
    const double badanLeft = 90;
    const double badanTop = 40;

    return SizedBox(
      width: 260,
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /// ================= BADAN =================
          if (w['badan'] != null)
            Positioned(
              left: badanLeft,
              top: badanTop,
              child: Image.network(w['badan'], height: 260),
            ),

          /// ================= LENGAN KIRI =================
          if (w['tangan_kiri_atas'] != null)
            Positioned(
              left: badanLeft + 20,
              top: badanTop + 70,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (d) {
                  _startDy = d.globalPosition.dy;
                  _startAngle = w['angle_kiri_atas'];
                },
                onPanUpdate: (d) {
                  final diff = d.globalPosition.dy - _startDy;
                  setState(() {
                    w['angle_kiri_atas'] = (_startAngle + diff * 0.015).clamp(
                      -1.2,
                      0.4,
                    );
                  });
                },
                child: SizedBox(
                  // 🔥 HITBOX BESAR
                  width: 120,
                  height: 160,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..translate(
                        25.0,
                        05.0,
                      ) // 🔴 PIVOT KIRI ATAS (ATUR SENDIRI)
                      ..rotateZ(w['angle_kiri_atas'])
                      ..translate(-25.0, -05.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.network(w['tangan_kiri_atas'], height: 110),
                        if (false) // ganti false kalau mau matiin
                          Positioned(left: 25, top: 05, child: _debugDot()),

                        /// SIKU KIRI
                        if (w['tangan_kiri_bawah'] != null)
                          Positioned(
                            left: -35,
                            top: 97,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onPanStart: (d) {
                                _startDy = d.globalPosition.dy;
                                _startAngle = w['angle_kiri_bawah'];
                              },
                              onPanUpdate: (d) {
                                final diff = d.globalPosition.dy - _startDy;
                                setState(() {
                                  w['angle_kiri_bawah'] =
                                      (_startAngle + diff * 0.02).clamp(
                                        -1.6,
                                        1.6,
                                      );
                                });
                              },
                              child: SizedBox(
                                width: 90,
                                height: 120,
                                child: Transform(
                                  transform: Matrix4.identity()
                                    ..translate(
                                      52.0,
                                      5.0,
                                    ) // 🔴 PIVOT SIKU KIRI
                                    ..rotateZ(w['angle_kiri_bawah'])
                                    ..translate(-52.0, -5.0),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        w['tangan_kiri_bawah'],
                                        height: 100,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          /// ================= LENGAN KANAN =================
          /// ================= LENGAN KANAN =================
          if (w['tangan_kanan_atas'] != null)
            Positioned(
              left: badanLeft + 150,
              top: badanTop + 45,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (d) {
                  _startDy = d.globalPosition.dy;
                  _startAngle = w['angle_kanan_atas'];
                },
                onPanUpdate: (d) {
                  final diff =
                      _startDy - d.globalPosition.dy; // 🔥 ARAH DIBALIK
                  setState(() {
                    w['angle_kanan_atas'] = (_startAngle + diff * 0.015).clamp(
                      -0.4,
                      1.2,
                    );
                  });
                },
                child: SizedBox(
                  width: 120,
                  height: 160,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..translate(10.0, 10.0) // 🔴 PIVOT KANAN ATAS
                      ..rotateZ(w['angle_kanan_atas'])
                      ..translate(-10.0, -10.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.network(w['tangan_kanan_atas'], height: 85),
                        if (false) // ganti false kalau mau matiin
                          Positioned(right: 10, top: 20, child: _debugDot()),

                        /// SIKU KANAN
                        if (w['tangan_kanan_bawah'] != null)
                          Positioned(
                            right: 30,
                            top: 65,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onPanStart: (d) {
                                _startDy = d.globalPosition.dy;
                                _startAngle = w['angle_kanan_bawah'];
                              },
                              onPanUpdate: (d) {
                                final diff = _startDy - d.globalPosition.dy;
                                setState(() {
                                  w['angle_kanan_bawah'] =
                                      (_startAngle + diff * 0.02).clamp(
                                        -1.6,
                                        1.6,
                                      );
                                });
                              },
                              child: SizedBox(
                                width: 100,
                                height: 110,
                                child: Transform(
                                  transform: Matrix4.identity()
                                    ..translate(
                                      93.0,
                                      12.0,
                                    ) // 🔴 PIVOT SIKU KANAN
                                    ..rotateZ(w['angle_kanan_bawah'])
                                    ..translate(-93.0, -12.0),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        w['tangan_kanan_bawah'],
                                        height: 80,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _debugDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }

  /// ===== BOTTOM SHEET PICKER =====
  void _showWayangPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: wayangList.length,
            itemBuilder: (_, i) {
              final wayang = wayangList[i];

              final thumbnail = wayang.thumbnail != null
                  ? ImageHelper.resolve(wayang.thumbnail!)
                  : "https://via.placeholder.com/150";

              return GestureDetector(
                onTap: () {
                  setState(() {
                    activeWayang.add({
                      'badan': wayang.badan != null
                          ? ImageHelper.resolve(wayang.badan!)
                          : null,
                      'tangan_kanan_atas': wayang.tanganKananAtas != null
                          ? ImageHelper.resolve(wayang.tanganKananAtas!)
                          : null,
                      'tangan_kanan_bawah': wayang.tanganKananBawah != null
                          ? ImageHelper.resolve(wayang.tanganKananBawah!)
                          : null,
                      'tangan_kiri_atas': wayang.tanganKiriAtas != null
                          ? ImageHelper.resolve(wayang.tanganKiriAtas!)
                          : null,
                      'tangan_kiri_bawah': wayang.tanganKiriBawah != null
                          ? ImageHelper.resolve(wayang.tanganKiriBawah!)
                          : null,
                      'position': const Offset(150, 200),

                      // ===== SUDUT =====
                      'angle_kiri_atas': 0.5,
                      'angle_kiri_bawah': 0.8,
                      'angle_kanan_atas': 0.4,
                      'angle_kanan_bawah': 0.3,
                    });
                  });
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Image.network(
                        thumbnail,
                        height: 90,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                      ),
                      const SizedBox(height: 6),
                      Text(wayang.nama),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
