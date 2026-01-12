// lib/config.dart

class AppConfig {
  // ============================================================
  // 🟢 CUKUP UBAH IP INI SAJA SETIAP GANTI WIFI / TEMPAT
  // ============================================================
  static const String serverIp = "192.168.56.157"; 
  // ============================================================

  static const String port = "8000";

  // Base URL API (Otomatis menggabungkan IP & Port)
  static const String baseUrl = "http://$serverIp:$port";
  
  // URL Endpoint Khusus (Opsional biar rapi)
  static const String apiUrl = "$baseUrl/api"; // Jika pakai prefix /api

  // URL Khusus Gambar Dalang (Folder Upload)
  static const String dalangImageUrl = "$baseUrl/static/uploads";
  
  // URL Khusus Gambar Artikel (Folder Upload)
  static const String articleImageUrl = "$baseUrl/static/uploads/thumbnails";
}