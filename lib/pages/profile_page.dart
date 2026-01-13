import 'package:flutter/material.dart';
import 'package:wayanusa/pages/detail_profile_page.dart';
import 'package:wayanusa/pages/notification_settings_page.dart';
import 'package:wayanusa/pages/help_support_page.dart';
import 'package:wayanusa/pages/about_app_page.dart';
import '../services/api_service.dart';

// ================= PROFILE PAGE =================
// StatefulWidget karena:
// - mengambil data dari API
// - menyimpan state loading
// - menggunakan animasi
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}


// ================= STATE PROFILE PAGE =================
class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {

  // Status loading saat data profile diambil dari API
  bool isLoading = true;

  // Nama user (default saat loading)
  String namaUser = "Memuat...";

  // Email user (placeholder sebelum API selesai)
  String emailUser = "wayanusa@user.com";

  // ================= ANIMASI =================

  // Controller utama animasi
  late AnimationController _animController;

  // Animasi geser dari bawah ke atas
  late Animation<Offset> _slideAnim;


  // ================= INIT STATE =================
  @override
  void initState() {
    super.initState();

    // Inisialisasi animation controller
    _animController = AnimationController(
      vsync: this, // sinkron dengan lifecycle widget
      duration: const Duration(milliseconds: 800),
    );

    // Animasi slide lembut (easeOutQuart)
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1), // posisi awal agak ke bawah
      end: Offset.zero,            // posisi akhir normal
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutQuart,
      ),
    );

    // Ambil data profile dari backend
    loadProfile();
  }


  // ================= DISPOSE =================
  @override
  void dispose() {
    // Hentikan animasi saat halaman ditutup
    _animController.dispose();
    super.dispose();
  }


  // ================= LOAD PROFILE =================
  // Mengambil data profile user dari API
  Future<void> loadProfile() async {
    try {
      // Panggil API profile
      final data = await ApiService.getProfile();

      // Cegah setState jika widget sudah dihapus
      if (!mounted) return;

      // Jika data berhasil didapat
      if (data != null) {
        setState(() {
          // Ambil nama user dari response API
          namaUser = data['name'] ?? "User Wayanusa";

          // Ambil email user dari response API
          emailUser = data['email'] ?? "email@wayanusa.com";

          // Matikan loading
          isLoading = false;
        });

        // Jalankan animasi setelah data siap
        _animController.forward();
      }
    } catch (e) {
      // Jika error (token invalid / koneksi gagal)
      if (mounted) {
        setState(() {
          namaUser = "User";
          isLoading = false;
        });

        // Tetap jalankan animasi
        _animController.forward();
      }
    }
  }


  // ================= LOGOUT CONFIRMATION =================
  // Dialog konfirmasi sebelum logout
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(

        // Bentuk dialog membulat
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        // Judul dialog
        title: const Text(
          "Keluar Akun?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        // Isi dialog
        content: const Text(
          "Apakah Anda yakin ingin keluar dari aplikasi Wayanusa?",
        ),

        // Tombol dialog
        actions: [

          // Tombol batal
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Batal",
              style: TextStyle(color: Colors.grey),
            ),
          ),

          // Tombol logout
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog

              // Hapus token login
              await ApiService.logout();

              if (!mounted) return;

              // Kembali ke halaman login
              // dan hapus semua halaman sebelumnya
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },

            // Style tombol logout
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            child: const Text(
              "Keluar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }


  // ================= BUILD UI =================
  @override
  Widget build(BuildContext context) {

    // Palet warna utama aplikasi
    const primaryColor = Color(0xFFD4A373);
    const secondaryColor = Color(0xFF4B3425);
    const bgColor = Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: bgColor,

      // Jika masih loading → tampilkan spinner
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor),
            )

          // Jika data sudah siap
          : SingleChildScrollView(
              child: Column(
                children: [

                  // ================= HEADER =================
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [

                      // Background gradient header
                      Container(
                        height: 240,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primaryColor, secondaryColor],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),

                        // Tombol back
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ================= AVATAR & INFO =================
                      Positioned(
                        bottom: -50, // avatar keluar dari header
                        child: Column(
                          children: [

                            // Border putih avatar
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),

                              // Avatar user
                              child: const CircleAvatar(
                                radius: 55,
                                backgroundColor: Color(0xFFFFF3E0),
                                backgroundImage: NetworkImage(
                                  "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Nama user
                            Text(
                              namaUser,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4B3425),
                              ),
                            ),

                            // Email user
                            Text(
                              emailUser,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 70), // ruang avatar

                  // ================= MENU =================
                  FadeTransition(
                    opacity: _animController,
                    child: SlideTransition(
                      position: _slideAnim,

                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // ===== AKUN =====
                            _buildSectionTitle("Akun Saya"),
                            _buildMenuCard([
                              _buildMenuItem(
                                icon: Icons.person_outline_rounded,
                                title: "Detail Profil",
                                subtitle: "Ubah data diri & foto",
                                color: Colors.blueAccent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const DetailProfilePage(),
                                    ),
                                  );
                                },
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                icon: Icons.notifications_outlined,
                                title: "Notifikasi",
                                subtitle: "Atur pesan masuk",
                                color: Colors.orangeAccent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const NotificationSettingsPage(),
                                    ),
                                  );
                                },
                              ),
                            ]),

                            const SizedBox(height: 25),

                            // ===== UMUM =====
                            _buildSectionTitle("Umum"),
                            _buildMenuCard([
                              _buildMenuItem(
                                icon: Icons.help_outline_rounded,
                                title: "Bantuan & Dukungan",
                                subtitle: "Hubungi admin Wayanusa",
                                color: Colors.purpleAccent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const HelpSupportPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                icon: Icons.info_outline_rounded,
                                title: "Tentang Aplikasi",
                                subtitle: "Versi 1.0.0 (Beta)",
                                color: Colors.teal,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AboutAppPage(),
                                    ),
                                  );
                                },
                              ),
                            ]),

                            const SizedBox(height: 25),

                            // ================= LOGOUT =================
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: _confirmLogout,
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  color: Colors.redAccent,
                                ),
                                label: const Text(
                                  "Keluar Aplikasi",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 16,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  backgroundColor:
                                      Colors.red.withOpacity(0.05),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }


  // ================= HELPER WIDGET =================

  // Judul section (Akun Saya, Umum)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  // Card pembungkus menu
  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // Garis pemisah antar menu
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey[200],
      indent: 60,
    );
  }

  // Item menu reusable
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

      // Icon bulat di kiri
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),

      // Judul menu
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),

      // Subjudul menu
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),

      // Icon panah kanan
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey,
        size: 20,
      ),
    );
  }
}
