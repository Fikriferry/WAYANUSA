import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // Palet Warna
  final Color primaryColor = const Color(0xFFD4A373);
  final Color secondaryColor = const Color(0xFF4B3425);
  final Color bgColor = const Color(0xFFF9F9F9);

  // State Variable (Nilai Awal)
  bool _pushEnabled = true;
  bool _promoEnabled = true;
  bool _activityEnabled = true;
  bool _soundEnabled = true;
  bool _emailNewsletter = false;

  // Fungsi saat switch diubah
  void _toggleSwitch(String key, bool value) {
    setState(() {
      switch (key) {
        case 'push': _pushEnabled = value; break;
        case 'promo': _promoEnabled = value; break;
        case 'activity': _activityEnabled = value; break;
        case 'sound': _soundEnabled = value; break;
        case 'email': _emailNewsletter = value; break;
      }
    });

    // Tampilkan feedback kecil
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? "Diaktifkan" : "Dinonaktifkan"),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        backgroundColor: secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        width: 150, // SnackBar kecil di tengah
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Atur Notifikasi",
          style: TextStyle(color: Color(0xFF4B3425), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4B3425)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEKSI 1: APLIKASI
            _buildSectionHeader("Aplikasi Wayanusa"),
            _buildSettingsCard([
              _buildSwitchTile(
                title: "Notifikasi Push",
                subtitle: "Terima pesan notifikasi di layar HP",
                icon: Icons.notifications_active_outlined,
                value: _pushEnabled,
                onChanged: (val) => _toggleSwitch('push', val),
              ),
              _buildDivider(),
              _buildSwitchTile(
                title: "Suara & Getar",
                subtitle: "Bunyikan nada saat ada notifikasi",
                icon: Icons.volume_up_outlined,
                value: _soundEnabled,
                onChanged: _pushEnabled ? (val) => _toggleSwitch('sound', val) : null, // Disabled kalau push mati
              ),
            ]),

            const SizedBox(height: 24),

            // SEKSI 2: KATEGORI INFO
            _buildSectionHeader("Jenis Informasi"),
            _buildSettingsCard([
              _buildSwitchTile(
                title: "Aktivitas & Sistem",
                subtitle: "Info update aplikasi dan keamanan",
                icon: Icons.settings_suggest_outlined,
                value: _activityEnabled,
                onChanged: (val) => _toggleSwitch('activity', val),
              ),
              _buildDivider(),
              _buildSwitchTile(
                title: "Promo & Penawaran",
                subtitle: "Diskon tiket wayang dan merchandise",
                icon: Icons.local_offer_outlined,
                value: _promoEnabled,
                onChanged: (val) => _toggleSwitch('promo', val),
              ),
            ]),

            const SizedBox(height: 24),

            // SEKSI 3: EMAIL
            _buildSectionHeader("Email & Buletin"),
            _buildSettingsCard([
              _buildSwitchTile(
                title: "Berlangganan Newsletter",
                subtitle: "Kirim artikel wayang mingguan ke email",
                icon: Icons.mark_email_unread_outlined,
                value: _emailNewsletter,
                onChanged: (val) => _toggleSwitch('email', val),
              ),
            ]),

            const SizedBox(height: 30),
            
            // Note Kaki
            Center(
              child: Text(
                "Pengaturan ini hanya berlaku untuk perangkat ini.",
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool)? onChanged, // Bisa null kalau disabled
  }) {
    // Warna icon berubah jadi abu-abu kalau switch mati/disabled
    final Color iconColor = (onChanged == null) 
        ? Colors.grey.withOpacity(0.3) 
        : (value ? const Color(0xFFD4A373) : Colors.grey);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: onChanged == null ? Colors.grey[400] : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFD4A373),
        activeTrackColor: const Color(0xFFD4A373).withOpacity(0.3),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 0.5, color: Colors.grey[200], indent: 60);
  }
}