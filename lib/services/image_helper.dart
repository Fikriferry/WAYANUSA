class ImageHelper {
  static const String _base =
      "http://192.168.1.184:8000/static/uploads/wayanggame/";

  static String resolve(String path) {
    // Normalisasi slash
    var p = path.replaceAll('\\', '/');

    // Kalau sudah full URL → ambil filename saja
    if (p.startsWith('http')) {
      return _base + p.split('/').last;
    }

    // Ambil NAMA FILE saja (buang folder apa pun)
    final filename = p.split('/').last;

    return _base + filename;
  }
}