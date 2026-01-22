import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  // Logika Cerdas: Cek apakah user sudah login atau belum
  Future<void> _checkAuth() async {
    // Beri jeda 3 detik agar user bisa menikmati logo Wayanusa
    await Future.delayed(const Duration(seconds: 3));

    final token = await ApiService.getToken();

    if (!mounted) return;

    if (token != null) {
      // Jika ada token, langsung ke Homepage
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Jika tidak ada, ke Welcome Screen
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Cream Bg Wayanusa
      body: Center(
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 1500),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Utama
              Image.asset('assets/welcome.png', width: 200),
              const SizedBox(height: 20),
              // Nama Aplikasi dengan font elegan
              Text(
                "WAYANUSA",
                style: GoogleFonts.cinzel(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: const Color(0xFF4B3425),
                ),
              ),
              const SizedBox(height: 10),
              // Loading Indicator tipis
              const SizedBox(
                width: 40,
                child: LinearProgressIndicator(
                  backgroundColor: Color(0xFFEEEEEE),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A373)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}