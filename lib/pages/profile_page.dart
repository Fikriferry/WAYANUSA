import 'package:flutter/material.dart';
import 'package:wayanusa/pages/detail_profile_page.dart';
import 'package:wayanusa/pages/notification_settings_page.dart';
import 'package:wayanusa/pages/help_support_page.dart';
import 'package:wayanusa/pages/about_app_page.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  String namaUser = "Memuat...";
  String emailUser = "wayanusa@user.com"; // Placeholder email

  // Animasi
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutQuart),
        );

    loadProfile();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    try {
      final data = await ApiService.getProfile();
      if (!mounted) return;

      if (data != null) {
        setState(() {
          namaUser = data['name'] ?? "User Wayanusa";
          emailUser = data['email'] ?? "email@wayanusa.com";
          isLoading = false;
        });
        _animController.forward(); // Jalankan animasi setelah data siap
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          namaUser = "User";
          isLoading = false;
        });
        _animController.forward();
      }
    }
  }

  // LOGOUT CONFIRMATION DIALOG
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Keluar Akun?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Apakah Anda yakin ingin keluar dari aplikasi Wayanusa?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog
              await ApiService.logout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Palet Warna
    const primaryColor = Color(0xFFD4A373);
    const secondaryColor = Color(0xFF4B3425);
    const bgColor = Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 1. HEADER SECTION (Gradient & Curve)
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Background Header
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

                      // Profile Info & Avatar
                      Positioned(
                        bottom: -50, // Membuat avatar "keluar" dari header
                        child: Column(
                          children: [
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
                              child: const CircleAvatar(
                                radius: 55,
                                backgroundColor: Color(0xFFFFF3E0),
                                backgroundImage: NetworkImage(
                                  "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                                ), // Placeholder Image
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              namaUser,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4B3425),
                              ),
                            ),
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

                  const SizedBox(
                    height: 70,
                  ), // Memberi ruang untuk avatar yg pop-out
                  // 2. MENU OPTIONS
                  FadeTransition(
                    opacity: _animController,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                      builder: (_) => const DetailProfilePage(),
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
                                  // Navigasi ke Halaman Pengaturan Notifikasi
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const NotificationSettingsPage(),
                                    ),
                                  );
                                }, // Fitur mendatang
                              ),
                            ]),

                            const SizedBox(height: 25),

                            _buildSectionTitle("Umum"),
                            _buildMenuCard([
                              _buildMenuItem(
                                icon: Icons.help_outline_rounded,
                                title: "Bantuan & Dukungan",
                                subtitle: "Hubungi admin Wayanusa",
                                color: Colors.purpleAccent,
                                onTap: () {
                                  // Navigasi
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HelpSupportPage(),
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
                                  // Navigasi ke Halaman Tentang
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

                            // LOGOUT BUTTON
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
                                  backgroundColor: Colors.red.withOpacity(0.05),
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

  // WIDGET HELPERS
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

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey[200],
      indent: 60,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey,
        size: 20,
      ),
    );
  }
}
