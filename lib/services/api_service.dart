import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../models/wayang_game.dart';
import 'google_auth.dart';
// import '../config.dart';

class ApiService {
  // ================= BASE URL =================
  static const String baseUrl =
      "https://monoclinic-superboldly-tobi.ngrok-free.dev/api";

  // ================= GET TOKEN =================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ================= REGISTER =================
  static Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    return response.statusCode == 201;
  }

  // ================= LOGIN =================
  static Future<bool> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        return true;
      }

      debugPrint("Login error: ${res.body}");
      return false;
    } catch (e) {
      debugPrint("Login exception: $e");
      return false;
    }
  }

  // ================= GET PROFILE =================
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final res = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else if (res.statusCode == 401) {
        // Jika token expired/salah, hapus saja biar user diminta login ulang
        await logout();
        return null;
      }
      return null;
    } catch (e) {
      debugPrint("Profile exception: $e");
      return null;
    }
  }

  // ================= UPDATE PROFILE =================
  static Future<bool> updateProfile({
    required String name,
    required String email,
    required String oldPassword, // Tambahkan ini
    String? password, // Ini password baru
    XFile? imageFile,
  }) async {
    final token = await getToken();
    if (token == null) return false;

    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/auth/profile'),
      );
      request.headers['Authorization'] = "Bearer $token";

      // Kirim data teks
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['old_password'] = oldPassword; // Kirim ke Flask

      if (password != null && password.isNotEmpty) {
        request.fields['password'] = password;
      }

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_pic',
            imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ================= PREDICT WAYANG =================
  static Future<Map<String, dynamic>?> predictWayang(XFile image) async {
    try {
      final uri = Uri.parse('$baseUrl/predict-wayang');
      final request = http.MultipartRequest('POST', uri);

      // BACA GAMBAR SEBAGAI BYTES (Agar support Web & Mobile)
      final bytes = await image.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: image.name, // Ambil nama file asli
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      print("Mengirim request ke $uri"); // Debug log

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error predict: $e");
      return null;
    }
  }

  // ================= CHATBOT =================
  static Future<String?> sendMessageSmart(String message, String mode) async {
    try {
      final url = Uri.parse("$baseUrl/chat-smart"); // Endpoint baru

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message,
          "mode": mode, // Kirim parameter mode
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['response'];
      } else {
        return "Maaf, server lagi sibuk (Error ${response.statusCode})";
      }
    } catch (e) {
      print("Error Chatbot: $e");
      return "Gagal terhubung ke server.";
    }
  }

  // === FITUR VIDEO WAYANG ===
  static Future<List<dynamic>> getVideos() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/videos"));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          return jsonResponse['data']; // Mengembalikan List Video
        }
      }
      return []; // Return list kosong jika gagal
    } catch (e) {
      print("Error getVideos: $e");
      return [];
    }
  }

  // === FITUR ARTIKEL ===
  static Future<List<dynamic>> getArticles({http.Client? client}) async {
    client ??= http.Client();

    try {
      final response = await client.get(Uri.parse("$baseUrl/articles"));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'success') {
          return jsonResponse['data'] as List<dynamic>;
        }
      }

      return [];
    } catch (e) {
      // untuk production
      print("Error getArticles: $e");
      return [];
    }
  }

  // === GET SINGLE ARTICLE ===
  static Future<Map<String, dynamic>?> getArticle(int id) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/articles/$id"));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          return jsonResponse['data'];
        }
      }
      return null;
    } catch (e) {
      print("Error getArticle: $e");
      return null;
    }
  }

  // ================= LOGOUT =================
  static Future<void> logout() async {
    try {
      // 1. Panggil logout Google untuk memastikan sesi Google terputus (signOut & disconnect)
      await GoogleAuthService.logout();

      // 2. Bersihkan token JWT dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      print("✅ Logout berhasil: Semua sesi dan token dibersihkan.");
    } catch (e) {
      print("⚠️ Error saat logout: $e");
    }
  }

  // ================= ulasan =================
  static Future<bool> postUlasan({
    required int rating,
    required String komentar,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/ulasan"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"rating": rating, "komentar": komentar}),
      );

      print("ULASAN STATUS: ${res.statusCode}");
      print(res.body);

      return res.statusCode == 201;
    } catch (e) {
      print("ULASAN ERROR: $e");
      return false;
    }
  }

  static String imageUrl(String path) {
    if (path.isEmpty) return "";

    // Ambil Root URL (Hapus /api dari baseUrl)
    final rootUrl = baseUrl.replaceAll('/api', '');

    // Bersihkan path dari backslash Windows dan kata 'static/' jika ada
    final cleaned = path.replaceAll('\\', '/').replaceFirst('static/', '');

    // Hasilnya: https://ngrok.dev/static/uploads/profile_pics/user_1.jpg
    return "$rootUrl/static/$cleaned";
  }

  // ================= WAYANG GAME =================
  static Future<List<WayangGame>> getWayangGameList() async {
    try {
      final url = "$baseUrl/wayang-game";
      print("🚀 Requesting: $url"); // Debug print

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['data'] != null) {
          final List data = json['data'];
          print("✅ Dapat ${data.length} wayang");
          return data.map((e) => WayangGame.fromJson(e)).toList();
        }
      }
      print("⚠️ Gagal: ${response.statusCode}");
      return [];
    } catch (e) {
      print("🔥 Error API: $e");
      return [];
    }
  }

  // ===============================================================
  // 2. GET DETAIL WAYANG (Untuk mulai main / merakit)
  // ===============================================================
  static Future<WayangGame?> getWayangGameDetail(int id) async {
    final url = "$baseUrl/wayang-game/$id";

    try {
      print("🔍 [API REQUEST] Detail Wayang ID $id: $url");

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Flask mengirim format: { "status": "success", "data": { ... } }
        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          print(
            "✅ [API SUCCESS] Detail ditemukan: ${jsonResponse['data']['nama']}",
          );

          return WayangGame.fromJson(jsonResponse['data']);
        }
      }

      print("❌ [API ERROR] Wayang tidak ditemukan (404/500)");
      return null;
    } catch (e) {
      print("🔥 [API ERROR] getWayangGameDetail: $e");
      return null;
    }
  }
}
