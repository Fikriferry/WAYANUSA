import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
class ApiService {
  // ================= BASE URL =================
  static const String baseUrl = "http://192.168.100.132:8000";


  // ================= TOKEN =================
  // Mengambil token login yang tersimpan di SharedPreferences
  static Future<String?> getToken() async {
    // Ambil instance SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Ambil value dengan key 'token'
    return prefs.getString('token');
  }


  // ================= REGISTER =================
  // Fungsi untuk mendaftarkan user baru
  static Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Kirim request POST ke endpoint register
      final res = await http.post(
        Uri.parse("$baseUrl/api/auth/register"),

        // Header menyatakan body berupa JSON
        headers: {"Content-Type": "application/json"},

        // Data dikirim dalam bentuk JSON
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      // Log response dari server
      debugPrint("REGISTER ${res.statusCode}: ${res.body}");

      // Jika status 201 → register sukses
      return res.statusCode == 201;
    } catch (e) {
      // Jika error (server mati / koneksi gagal)
      debugPrint("REGISTER ERROR: $e");
      return false;
    }
  }


  // ================= LOGIN =================
  // Fungsi login user
  static Future<bool> login(String email, String password) async {
    try {
      // Kirim POST ke endpoint login
      final res = await http.post(
        Uri.parse("$baseUrl/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      // Log response
      debugPrint("LOGIN ${res.statusCode}: ${res.body}");

      // Jika login berhasil
      if (res.statusCode == 200) {
        // Decode JSON response
        final data = jsonDecode(res.body);

        // Simpan token ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);

        return true;
      }
      return false;
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      return false;
    }
  }


  // ================= PROFILE =================
  // Mengambil data profile user yang sedang login
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      // Ambil token login
      final token = await getToken();

      // Jika belum login, hentikan proses
      if (token == null) return null;

      // Request GET ke endpoint profile
      final res = await http.get(
        Uri.parse("$baseUrl/api/auth/profile"),
        headers: {
          // Token dikirim via Authorization Bearer
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("PROFILE ${res.statusCode}: ${res.body}");

      // Jika sukses, return data profile
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      debugPrint("PROFILE ERROR: $e");
      return null;
    }
  }


  // ================= LOGOUT =================
  // Menghapus token login dari SharedPreferences
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }


  // ================= PREDICT WAYANG =================
  // Mengirim gambar ke backend untuk AI prediksi wayang
  static Future<Map<String, dynamic>?> predictWayang(XFile image) async {
    try {
      // Endpoint AI predict
      final uri = Uri.parse("$baseUrl/api/predict-wayang");

      // Gunakan MultipartRequest karena kirim file
      final request = http.MultipartRequest("POST", uri);

      // Baca isi file gambar menjadi byte
      final bytes = await image.readAsBytes();

      // Tambahkan file gambar ke request
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',            // nama field di backend
          bytes,              // isi file
          filename: image.name,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Kirim request ke server
      final streamed = await request.send();

      // Ambil response dari stream
      final response = await http.Response.fromStream(streamed);

      debugPrint("PREDICT ${response.statusCode}: ${response.body}");

      // Jika sukses, kembalikan hasil prediksi
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint("PREDICT ERROR: $e");
      return null;
    }
  }


  // ================= CHATBOT =================
  // Mengirim pesan ke chatbot AI
  static Future<String?> sendMessageSmart(String message, String mode) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/chat-smart"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message, // isi chat user
          "mode": mode,       // mode AI (misal: wayang / edukasi)
        }),
      );

      debugPrint("CHAT ${res.statusCode}: ${res.body}");

      // Ambil jawaban AI
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['response'];
      }
      return null;
    } catch (e) {
      debugPrint("CHAT ERROR: $e");
      return null;
    }
  }


  // ================= VIDEO WAYANG =================
  // Mengambil daftar video wayang dari backend
  static Future<List<dynamic>> getVideos() async {
    try {
      // Request GET ke endpoint video
      final res = await http.get(Uri.parse("$baseUrl/api/videos"));

      // Jika sukses
      if (res.statusCode == 200) {
        final jsonRes = jsonDecode(res.body);

        // Ambil array video dari key "data"
        return jsonRes['data'] ?? [];
      }
      return [];
    } catch (e) {
      debugPrint("VIDEO ERROR: $e");
      return [];
    }
  }


  // ================= ARTIKEL =================
  // Mengambil daftar artikel dari backend
  static Future<List<dynamic>> getArticles() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/articles"));

      if (res.statusCode == 200) {
        final jsonRes = jsonDecode(res.body);
        return jsonRes['data'] ?? [];
      }
      return [];
    } catch (e) {
      debugPrint("ARTICLE ERROR: $e");
      return [];
    }
  }


  // ================= ulasan =================
  static Future<bool> postUlasan({
    required int rating,
    required String komentar,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/ulasan"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "rating": rating,
          "komentar": komentar,
        }),
      );

      print("ULASAN STATUS: ${res.statusCode}");
      print(res.body);

      return res.statusCode == 201;
    } catch (e) {
      print("ULASAN ERROR: $e");
      return false;
    }
  }
}
