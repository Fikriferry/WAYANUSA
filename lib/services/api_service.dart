import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  // ================= BASE URL =================
  static const String baseUrl = "http://192.168.100.222:8000/api";

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
      Uri.parse("$baseUrl/api/auth/register"),
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
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }

      debugPrint("Profile error: ${res.body}");
      return null;
    } catch (e) {
      debugPrint("Profile exception: $e");
      return null;
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
  static Future<List<dynamic>> getArticles() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/articles"));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          return jsonResponse['data'];
        }
      }
      return [];
    } catch (e) {
      print("Error getArticles: $e");
      return [];
    }
  }

  // ================= LOGOUT =================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
