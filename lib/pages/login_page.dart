import 'package:flutter/material.dart';
import 'register_page.dart';
import 'homepage.dart';
import '../services/api_service.dart';


// ================= LOGIN PAGE =================
// StatefulWidget karena:
// - menyimpan state loading
// - controller TextField
// - animation controller
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


// ================= STATE LOGIN PAGE =================
class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  // Controller untuk mengambil teks dari input email
  final TextEditingController emailController = TextEditingController();

  // Controller untuk mengambil teks dari input password
  final TextEditingController passwordController = TextEditingController();

  // Status loading (untuk disable tombol & tampilkan spinner)
  bool isLoading = false;

  // Controller animasi utama
  late AnimationController _animController;

  // Animasi fade (opacity)
  late Animation<double> _fadeAnim;

  // Animasi slide (posisi dari bawah ke atas)
  late Animation<Offset> _slideAnim;


  // ================= INIT STATE =================
  // Dipanggil sekali saat halaman pertama kali dibuat
  @override
  void initState() {
    super.initState();

    // Inisialisasi AnimationController
    _animController = AnimationController(
      vsync: this, // sinkronisasi animasi dengan lifecycle widget
      duration: const Duration(milliseconds: 800), // durasi animasi
    );

    // Animasi fade (0 → 1)
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    // Animasi slide dari bawah ke posisi normal
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2), // posisi awal (sedikit ke bawah)
      end: Offset.zero,            // posisi akhir (normal)
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ),
    );

    // Jalankan animasi
    _animController.forward();
  }


  // ================= DISPOSE =================
  // Dipanggil saat halaman ditutup
  @override
  void dispose() {
    // Hentikan dan hapus animasi
    _animController.dispose();

    // Hapus controller TextField (hindari memory leak)
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }


  // ================= LOGIN FUNCTION =================
  // Proses login user ke backend
  Future<void> _login() async {
    // Ambil & rapikan input user
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validasi input kosong
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email dan Password tidak boleh kosong!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Aktifkan loading
    setState(() => isLoading = true);

    // Panggil API login
    final success = await ApiService.login(email, password);

    // Matikan loading
    setState(() => isLoading = false);

    // Jika login berhasil
    if (success) {
      // Pindah ke halaman utama & hapus halaman login dari stack
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeWayangPage()),
      );
    } else {
      // Jika login gagal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email atau password salah"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  // ================= BUILD UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(

        // Background gradient emas-coklat
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB6783D),
              Color(0xFFD4A373),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Center(

            // Animasi fade
            child: FadeTransition(
              opacity: _fadeAnim,

              // Animasi slide
              child: SlideTransition(
                position: _slideAnim,

                // Card login
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 24),

                  child: Padding(
                    padding: const EdgeInsets.all(24),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // Logo aplikasi
                        Image.asset('assets/logo.png', width: 100),
                        const SizedBox(height: 16),

                        // Judul
                        const Text(
                          "Selamat Datang",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subjudul
                        const Text(
                          "Silakan login untuk melanjutkan",
                          style: TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 20),

                        // ================= INPUT EMAIL =================
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ================= INPUT PASSWORD =================
                        TextField(
                          controller: passwordController,
                          obscureText: true, // sembunyikan password
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          // Tekan enter → langsung login
                          onSubmitted: (_) => _login(),
                        ),

                        const SizedBox(height: 24),

                        // ================= BUTTON LOGIN =================
                        ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB6783D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),

                          // Jika loading tampil spinner
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Masuk",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 16),

                        // ================= REGISTER LINK =================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Belum punya akun? "),
                            GestureDetector(
                              onTap: () {
                                // Pindah ke halaman register
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Daftar",
                                style: TextStyle(
                                  color: Color(0xFFB6783D),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
