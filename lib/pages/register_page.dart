import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  // Controller untuk Input
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Status State
  bool isLoading = false;
  bool _isObscure = true;
  bool _isObscureConfirm = true;

  // Controller Animasi
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
    
    // ANIMASI GESER DARI KANAN KE KIRI
    _slideAnim = Tween<Offset>(
      begin: const Offset(1.0, 0.0), 
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutQuart));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> handleRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnack("Waduh, isi semua datanya dulu ya!", Colors.orange);
      return;
    }

    if (password != confirmPassword) {
      _showSnack("Konfirmasi kata sandinya beda euy!", Colors.redAccent);
      return;
    }

    setState(() => isLoading = true);
    final success = await ApiService.register(name: name, email: email, password: password);
    setState(() => isLoading = false);

    if (success) {
      _showSnack("Berhasil! Silakan masuk ke Wayanusa", Colors.green);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    } else {
      _showSnack("Daftar gagal, coba lagi nanti ya", Colors.redAccent);
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
          // 1. BACKGROUND GRADIENT MEWAH
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [deepBrown, primaryGold],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. KONTEN UTAMA
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          "Selamat Datang!",
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // STACK UNTUK LOGO MELAYANG
                        Stack(
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.none,
                          children: [
                            // KARTU FORM (Diberi margin top 50 agar logo bisa overlap)
                            Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: _buildRegisterForm(primaryGold, deepBrown),
                            ),
                            
                            // LOGO DALAM LINGKARAN DEKORATIF
                            Positioned(
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 25,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/welcome.png',
                                  width: 75,
                                  height: 75,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 35),
                        
                        // FOOTER NAVIGASI KE LOGIN
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Sudah punya akun? ", style: GoogleFonts.poppins(color: Colors.white70)),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context, 
                                MaterialPageRoute(builder: (_) => const LoginPage())
                              ),
                              child: Text(
                                "Masuk Sekarang",
                                style: GoogleFonts.poppins(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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

  Widget _buildRegisterForm(Color accent, Color dark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 30), // Top padding besar untuk area logo
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), 
            blurRadius: 30, 
            offset: const Offset(0, 20)
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Mulai Perjalananmu",
            style: GoogleFonts.poppins(
              fontSize: 22, 
              fontWeight: FontWeight.bold, 
              color: dark
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Daftar dan lestarikan budaya bersama kami",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          
          _buildTextField(controller: nameController, label: "Nama Lengkap", icon: Icons.person_outline_rounded),
          const SizedBox(height: 16),
          _buildTextField(
            controller: emailController, 
            label: "Alamat Email", 
            icon: Icons.alternate_email_rounded, 
            type: TextInputType.emailAddress
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: passwordController,
            label: "Kata Sandi",
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            obscure: _isObscure,
            onToggle: () => setState(() => _isObscure = !_isObscure),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: confirmPasswordController,
            label: "Konfirmasi Sandi",
            icon: Icons.verified_user_outlined,
            isPassword: true,
            obscure: _isObscureConfirm,
            onToggle: () => setState(() => _isObscureConfirm = !_isObscureConfirm),
          ),
          const SizedBox(height: 35),
          
          // TOMBOL DAFTAR DENGAN GRADIENT PREMIUM
          Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [dark, const Color(0xFF63422B)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: dark.withOpacity(0.4), 
                  blurRadius: 15, 
                  offset: const Offset(0, 8)
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24, 
                      height: 24, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                    )
                  : Text(
                      "DAFTAR SEKARANG", 
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, 
                        color: Colors.white, 
                        letterSpacing: 1.2,
                        fontSize: 15
                      )
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscure : false,
      keyboardType: type,
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFFD4A373), size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 20), 
                onPressed: onToggle
              )
            : null,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), 
          borderSide: BorderSide(color: Colors.grey[200]!)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), 
          borderSide: const BorderSide(color: Color(0xFFD4A373), width: 1.5)
        ),
      ),
    );
  }
}