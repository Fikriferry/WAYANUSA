import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import '../config.dart';

class DalangApi {
  // Pastikan IP dan Port sesuai dengan settingan Flask kamu
  static const String baseUrl = "http://192.168.48.150:8000/api";

  // ================= HELPER PARSING (PENTING) =================
  // Agar aplikasi tidak error jika data dari API null atau beda tipe
  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  // ... (Kode getToken, register, login, predictWayang, sendMessage TETAP SAMA) ...
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ...

  // ================= DATA DALANG (UPDATED) =================
  
  // 1. GET ALL DALANG
  static Future<List<Map<String, dynamic>>> getDalang() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dalang'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Flask mengembalikan: { "data": [ ... ] }
        // Jadi kita harus ambil key ['data'] dulu
        final List<dynamic> dataList = jsonResponse['data'] ?? [];

        return dataList.map<Map<String, dynamic>>((item) {
          return {
            "id": _parseInt(item['id']),
            "nama": item['nama'] ?? "Tanpa Nama",
            "alamat": item['alamat'] ?? "-",
            // Flask kamu mengirim 'foto', bukan 'foto_url'
            "foto": item['foto'] ?? "", 
            "latitude": _parseDouble(item['latitude']),
            "longitude": _parseDouble(item['longitude']),
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print("Error getDalang: $e");
      return [];
    }
  }

  // 2. GET DETAIL DALANG (Opsional, jika nanti dibutuhkan)
  static Future<Map<String, dynamic>?> getDalangById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dalang/$id'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // Sesuaikan jika flask mengembalikan { "data": {...} } atau langsung {...}
        final data = jsonResponse['data'] ?? jsonResponse; 
        
        return {
          "id": _parseInt(data['id']),
          "nama": data['nama'] ?? "",
          "alamat": data['alamat'] ?? "",
          "foto": data['foto'] ?? "",
          "latitude": _parseDouble(data['latitude']),
          "longitude": _parseDouble(data['longitude']),
        };
      }
      return null;
    } catch (e) {
      print("Error getDetail: $e");
      return null;
    }
  }

  // ... (Sisa kode seperti sendMessage, dll biarkan saja) ...
}