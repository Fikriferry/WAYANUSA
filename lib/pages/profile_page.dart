import 'package:flutter/material.dart';
import 'package:wayanusa/pages/detail_profile_page.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isNotificationOn = true;
  bool isLoading = true;
  String namaUser = "-";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final data = await ApiService.getProfile();

      if (!mounted) return;

      if (data != null && data['name'] != null) {
        setState(() {
          namaUser = data['name'];
          isLoading = false;
        });
      } else {
        setState(() {
          namaUser = "User";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        namaUser = "User";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profil",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🧑 Header
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: Color(0xFFFFB74D),
                        child: Icon(Icons.person,
                            size: 45, color: Colors.brown),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          namaUser,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.brown),
                        onPressed: () async {
                          await ApiService.logout();

                          if (!mounted) return;

                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  ProfileMenuItem(
                    icon: Icons.person_outline,
                    text: "Profil Pengguna",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DetailProfilePage(),
                        ),
                      );
                    },
                  ),

                  // const SizedBox(height: 10),

                  // ProfileMenuItem(
                  //   icon: Icons.lock_outline,
                  //   text: "Ubah Sandi",
                  //   onTap: () {},
                  // ),
                ],
              ),
            ),
    );
  }
}

// ================= MENU ITEM =================
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.brown),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
