import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profil Pengguna'),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Avatar profil
            CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xFFFFC107),
              child: ClipOval(
                child: Image.asset(
                  'assets/profil.png', 
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Nama Lengkap
            _buildLabel("Nama Lengkap"),
            _buildTextField("Arya"),

            const SizedBox(height: 15),

            // Email
            _buildLabel("Email"),
            _buildTextField("arya@gmail.com"),

            const SizedBox(height: 15),

            // Nomor Telepon
            _buildLabel("No. Telepon"),
            _buildTextField("817-0098-8870"),

            const SizedBox(height: 30),

            // Tombol Simpan
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB6783D),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Label
  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // Widget TextField
  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
