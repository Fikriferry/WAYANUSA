import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DetailProfilePage extends StatefulWidget {
  const DetailProfilePage({super.key});

  @override
  State<DetailProfilePage> createState() => _DetailProfilePageState();
}

class _DetailProfilePageState extends State<DetailProfilePage> {
  final idController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data = await ApiService.getProfile();

    if (data != null) {
      idController.text = data['id'].toString();
      nameController.text = data['name'] ?? '-';
      emailController.text = data['email'] ?? '-';
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Saya"),
        centerTitle: true,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ===== AVATAR =====
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: Color(0xFFB6783D),
                    child: Icon(
                      Icons.person,
                      size: 55,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Akun Pengguna",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ===== CARD DATA =====
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildField(
                            label: "User ID",
                            icon: Icons.badge_outlined,
                            controller: idController,
                          ),
                          const SizedBox(height: 16),

                          _buildField(
                            label: "Nama Lengkap",
                            icon: Icons.person_outline,
                            controller: nameController,
                          ),
                          const SizedBox(height: 16),

                          _buildField(
                            label: "Email",
                            icon: Icons.email_outlined,
                            controller: emailController,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
