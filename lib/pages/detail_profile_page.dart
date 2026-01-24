import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class DetailProfilePage extends StatefulWidget {
  const DetailProfilePage({super.key});

  @override
  State<DetailProfilePage> createState() => _DetailProfilePageState();
}

class _DetailProfilePageState extends State<DetailProfilePage> {
  bool _isLoading = true;
  bool _isUpdating = false;
  
  // Visibility state
  bool _obscureNew = true;
  
  XFile? _imageFile;
  String? _currentImageUrl;

  // Controllers
  final _oldPasswordController = TextEditingController(); // Diisi lewat Dialog nanti
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); // Ini untuk Password Baru
  
  final ImagePicker _picker = ImagePicker();

  final Color primaryColor = const Color(0xFFD4A373);
  final Color secondaryColor = const Color(0xFF4B3425);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final profile = await ApiService.getProfile();
    if (profile != null && mounted) {
      _nameController.text = profile['name'] ?? '';
      _emailController.text = profile['email'] ?? '';
      _currentImageUrl = profile['profile_pic'];
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (selected != null) {
      final file = File(selected.path);
      final int fileSize = await file.length();
      if (fileSize > 2 * 1024 * 1024) {
        _showSnackBar("Ukuran foto terlalu besar (Max 2MB)", Colors.orange);
        return;
      }
      setState(() => _imageFile = selected);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // 1. Fungsi ini dipanggil saat tombol Simpan di klik
  void _onSaveButtonPressed() {
    // Validasi dasar dulu
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      _showSnackBar("Nama dan Email tidak boleh kosong", Colors.orange);
      return;
    }

    // Tampilkan Dialog Password Lama
    _showPasswordConfirmationDialog();
  }

  // 2. Dialog untuk meminta Password Lama
  Future<void> _showPasswordConfirmationDialog() async {
    _oldPasswordController.clear(); // Reset field dialog
    bool obscureDialogPass = true; // State lokal untuk dialog

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Butuh StatefulBuilder agar bisa toggle eye icon di dialog
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                "Konfirmasi Perubahan",
                style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Demi keamanan, mohon masukkan password lama Anda untuk menyimpan perubahan."),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _oldPasswordController,
                    obscureText: obscureDialogPass,
                    decoration: InputDecoration(
                      labelText: "Password Lama",
                      prefixIcon: Icon(Icons.vpn_key, color: primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureDialogPass ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscureDialogPass = !obscureDialogPass;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_oldPasswordController.text.isEmpty) {
                      // Show toast/snackbar is tricky inside dialog, using simple return logic
                      return; 
                    }
                    Navigator.pop(context); // Tutup dialog
                    _executeSaveProfile(); // Lanjut ke proses API
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Konfirmasi", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 3. Proses API (Dijalankan setelah dialog dikonfirmasi)
  Future<void> _executeSaveProfile() async {
    if (_oldPasswordController.text.isEmpty) {
      _showSnackBar("Password lama wajib diisi!", Colors.red);
      return;
    }

    setState(() => _isUpdating = true);

    try {
      bool success = await ApiService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        oldPassword: _oldPasswordController.text, // Ambil dari controller dialog tadi
        password: _passwordController.text.trim(), // Password baru (opsional)
        imageFile: _imageFile,
      );

      if (mounted) {
        if (success) {
          _showSnackBar("Profil berhasil diperbarui", Colors.green);
          _oldPasswordController.clear();
          _passwordController.clear();
          _loadProfile(); // Reload data terbaru
        } else {
          _showSnackBar("Gagal! Password lama salah atau server error.", Colors.red);
        }
      }
    } catch (e) {
      _showSnackBar("Terjadi kesalahan: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildSectionCard(
                          title: "Informasi Pribadi",
                          icon: Icons.person_outline,
                          children: [
                            _buildTextField(controller: _nameController, label: "Nama Lengkap", icon: Icons.badge_outlined),
                            const SizedBox(height: 16),
                            _buildTextField(controller: _emailController, label: "Email", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSectionCard(
                          title: "Keamanan Akun",
                          icon: Icons.lock_outline,
                          children: [
                            // NOTE: Password Lama dihapus dari sini
                            _buildTextField(
                              controller: _passwordController,
                              label: "Password Baru (Opsional)",
                              icon: Icons.add_moderator_outlined,
                              isPassword: true,
                              obscureText: _obscureNew,
                              onToggle: () => setState(() => _obscureNew = !_obscureNew),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "* Kosongkan jika tidak ingin mengganti password",
                              style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        _buildSaveButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // --- Widget Builders (Header, SectionCard, TextField sama seperti sebelumnya) ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path))
                        : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                            ? NetworkImage(ApiService.imageUrl(_currentImageUrl!))
                            : null) as ImageProvider?,
                    child: (_imageFile == null && (_currentImageUrl == null || _currentImageUrl!.isEmpty))
                        ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: secondaryColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: primaryColor),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: secondaryColor)),
            ],
          ),
          const Divider(height: 25),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: secondaryColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        suffixIcon: isPassword
            ? IconButton(icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20), onPressed: onToggle)
            : null,
        filled: true,
        fillColor: const Color(0xFFF1F4F8),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor)),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        // Di sini kita panggil _onSaveButtonPressed, BUKAN _saveProfile langsung
        onPressed: _isUpdating ? null : _onSaveButtonPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          shadowColor: primaryColor.withOpacity(0.4),
        ),
        child: _isUpdating
            ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : const Text("Simpan Perubahan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}