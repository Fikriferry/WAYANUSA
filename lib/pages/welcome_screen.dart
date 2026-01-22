import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    // Animasi denyut cahaya emas
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Animasi melayang untuk Cepot
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGold = Color(0xFFD4AF37);
    const Color darkBrown = Color(0xFF4A3B2A);
    const Color creamBg = Color(0xFFFDFBF7);

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // 1. BACKGROUND BATIK DENGAN GRADIENT OVERLAY
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/batik_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Container(color: Colors.orange[50]),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  creamBg.withOpacity(0.0),
                  creamBg.withOpacity(0.8),
                  creamBg,
                ],
              ),
            ),
          ),

          // 2. KONTEN UTAMA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // TAGLINE & JUDUL (Fade In Animation)
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Column(
                            children: [
                              Text(
                                "WAYANUSA",
                                style: GoogleFonts.cinzel(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: darkBrown,
                                  letterSpacing: 8,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                height: 2,
                                width: 100,
                                color: primaryGold,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                "Menelusuri Warisan,\nMengukir Masa Depan",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.philosopher(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  color: darkBrown.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  // CENTERPIECE: GUNUNGAN DENGAN PULSING HALO
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Lingkaran Cahaya Berdenyut
                        FadeTransition(
                          opacity: Tween<double>(begin: 0.3, end: 0.8).animate(_pulseController),
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryGold.withOpacity(0.4),
                                  blurRadius: 50,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Logo Gunungan
                        Image.asset(
                          'assets/welcome.png',
                          width: 350,
                          errorBuilder: (c, o, s) => Icon(Icons.change_history, size: 200, color: darkBrown),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // TOMBOL MULAI (MODERN STYLE)
                  _buildAnimatedButton(context, darkBrown),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),

          // 3. MASCOT CEPOT (FLOATING ANIMATION)
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Positioned(
                right: 0,
                bottom: 110 + (15 * _floatController.value), // Efek melayang
                child: child!,
              );
            },
            child: Image.asset(
              'assets/images/cepot_mascot.png',
              height: 160,
              errorBuilder: (c, o, s) => const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton(BuildContext context, Color color) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "MULAI JELAJAH",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}