class ImageHelper {
  // ⚠️ GANTI DENGAN URL NGROK TERBARU KAMU
  static const String baseUrl = "https://monoclinic-superboldly-tobi.ngrok-free.dev"; 

  static String resolve(String path) {
    if (path.isEmpty) return "https://via.placeholder.com/150";

    // Jika sudah full URL (misal dari API yang sudah saya perbaiki sebelumnya), langsung return
    if (path.startsWith('http')) return path;

    // Bersihkan path dari karakter aneh
    String cleanPath = path.replaceAll('\\', '/');
    if (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);
    
    // Gabungkan
    return "$baseUrl/$cleanPath";
  }
}