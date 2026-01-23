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
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Memberikan jeda 3 detik agar user bisa melihat logo
    await Future.delayed(const Duration(seconds: 3));

    // Ambil token dari ApiService
    final token = await ApiService.getToken();

    if (!mounted) return;

    if (token != null) {
      // Jika token ada, lanjut ke Homepage
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Jika tidak ada, ke Welcome Screen
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Sesuaikan dengan warna tema kamu
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Gunungan
            Image.asset('assets/welcome.png', width: 180),
            const SizedBox(height: 24),
            // Nama Aplikasi
            Text(
              "WAYANUSA",
              style: GoogleFonts.cinzel(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
                color: const Color(0xFF4B3425),
              ),
            ),
            const SizedBox(height: 20),
            // Indikator loading yang minimalis
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A373)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}