import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_page.dart';
import 'homepage.dart';
import '../services/api_service.dart';
import '../services/google_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _isObscure = true; // Untuk toggle password

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.elasticOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack("Waduh, email & password jangan dikosongin euy!", Colors.orange);
      return;
    }

    setState(() => isLoading = true);
    final success = await ApiService.login(email, password);
    setState(() => isLoading = false);

    if (success) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeWayangPage()));
    } else {
      _showSnack("Email atau password salah, coba cek lagi ya!", Colors.redAccent);
    }
  }

  Future<void> _loginGoogle() async {
    setState(() => isLoading = true);
    final success = await GoogleAuthService.loginWithGoogle();
    setState(() => isLoading = false);

    if (success) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeWayangPage()));
    } else {
      _showSnack("Gagal masuk lewat Google euy!", Colors.redAccent);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGold = const Color(0xFFD4A373);
    final Color deepBrown = const Color(0xFF4B3425);

    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND GRADIENT & PATTERN
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [deepBrown, primaryGold],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Aksen Batik (Opsional, gunakan opacity rendah)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset('assets/images/batik_bg.png', fit: BoxFit.cover, errorBuilder: (c, o, s) => Container()),
            ),
          ),

          // 2. KONTEN UTAMA
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      children: [
                        // LOGO SECTION
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: Image.asset('assets/welcome.png', width: 120),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "Selamat Datang!",
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          "Silahkan masuk untuk melanjutkan",
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 40),

                        // FORM SECTION (GLASSMORPHISM)
                        _buildLoginForm(primaryGold),

                        const SizedBox(height: 30),

                        // FOOTER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Belum punya akun? ", style: GoogleFonts.poppins(color: Colors.white70)),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                              child: Text(
                                "Daftar Sekarang",
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
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
        ],
      ),
    );
  }

  Widget _buildLoginForm(Color accent) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: emailController,
            label: "Email",
            icon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: passwordController,
            label: "Password",
            icon: Icons.lock_outline_rounded,
            isPassword: true,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text("Lupa Password?", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
          ),
          const SizedBox(height: 25),
          
          // TOMBOL LOGIN UTAMA
          _buildPrimaryButton(accent),
          
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text("Atau", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          const SizedBox(height: 20),

          // GOOGLE LOGIN
          _buildGoogleButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _isObscure : false,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFFD4A373)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              )
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD4A373), width: 1.5)),
      ),
    );
  }

  Widget _buildPrimaryButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4B3425),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
        ),
        child: isLoading
            ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text("MASUK KE WAYANUSA", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white)),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton(
      onPressed: isLoading ? null : _loginGoogle,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gunakan URL yang lebih pendek dan stabil, atau gunakan Icon sebagai fallback
          Image.network(
            'https://www.gstatic.com/images/branding/product/1x/gsa_512dp.png',
            height: 22,
            // PENTING: Supaya tidak overflow kalau link mati lagi
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.g_mobiledata, color: Colors.blue, size: 30);
            },
          ),
          const SizedBox(width: 12),
          Text(
            "Masuk dengan Google",
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}