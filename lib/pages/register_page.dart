import 'package:flutter/material.dart';
import 'login_page.dart';
import '../services/api_service.dart';

/// =====================================================
/// REGISTER PAGE
/// Fungsi:
/// - Registrasi user baru
/// - Validasi input
/// - Kirim data ke API
/// - Animasi masuk halaman
/// - Navigasi ke LoginPage jika sukses
/// =====================================================
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {

  /// -----------------------------
  /// TEXT CONTROLLERS
  /// Digunakan untuk mengambil nilai input user
  /// -----------------------------
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  /// -----------------------------
  /// STATE LOADING
  /// true  -> tombol disable + loading muncul
  /// false -> tombol aktif
  /// -----------------------------
  bool isLoading = false;

  /// -----------------------------
  /// ANIMASI
  /// Fade + Slide dari bawah
  /// -----------------------------
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  /// =====================================================
  /// INIT STATE
  /// Dipanggil pertama kali saat halaman dibuka
  /// =====================================================
  @override
  void initState() {
    super.initState();

    /// Controller animasi utama
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    /// Animasi fade (opacity 0 -> 1)
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    /// Animasi slide (dari bawah ke atas)
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2), // 20% dari bawah
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    /// Jalankan animasi
    _animController.forward();
  }

  /// =====================================================
  /// DISPOSE
  /// Membersihkan controller untuk mencegah memory leak
  /// =====================================================
  @override
  void dispose() {
    _animController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// =====================================================
  /// HANDLE REGISTER
  /// - Validasi input
  /// - Panggil API register
  /// - Tampilkan notifikasi
  /// =====================================================
  Future<void> handleRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    /// Validasi field kosong
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnack("Semua field wajib diisi", Colors.red);
      return;
    }

    /// Validasi password & konfirmasi
    if (password != confirmPassword) {
      _showSnack("Konfirmasi kata sandi tidak sama", Colors.red);
      return;
    }

    /// Aktifkan loading
    setState(() => isLoading = true);

    /// Panggil API register
    final success = await ApiService.register(
      name: name,
      email: email,
      password: password,
    );

    /// Matikan loading
    setState(() => isLoading = false);

    /// Jika berhasil -> ke login
    if (success) {
      _showSnack("Registrasi berhasil, silakan login", Colors.green);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      _showSnack("Registrasi gagal", Colors.red);
    }
  }

  /// =====================================================
  /// SNACKBAR HELPER
  /// =====================================================
  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
      ),
    );
  }

  /// =====================================================
  /// BUILD UI
  /// =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        /// Background gradasi khas Wayang / Wayanusa
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

            /// Animasi masuk
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,

                /// Card utama
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 24),

                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          /// LOGO
                          Image.asset('assets/welcome.png', width: 100),
                          const SizedBox(height: 16),

                          /// JUDUL
                          const Text(
                            "Buat Akun Baru",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Daftar untuk mulai menjelajah Wayang",
                            style: TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 20),

                          /// NAMA
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: "Nama Lengkap",
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          /// EMAIL
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          /// PASSWORD
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Kata Sandi",
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          /// KONFIRMASI PASSWORD
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Konfirmasi Kata Sandi",
                              prefixIcon: const Icon(Icons.lock_reset),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// TOMBOL DAFTAR
                          ElevatedButton(
                            onPressed: isLoading ? null : handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB6783D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize:
                                  const Size(double.infinity, 50),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Daftar",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 16),

                          /// LINK KE LOGIN
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Sudah punya akun? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Masuk",
                                  style: TextStyle(
                                    color: Color(0xFFB6783D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
