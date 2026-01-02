import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  // 🔴 GANTI SESUAI DEVICE
  static const String baseUrl = "http://localhost:8000";

  // ================= SAVE TOKEN =================
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // ================= LOGIN =================
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // 🔑 SIMPAN TOKEN
      await saveToken(data['access_token']);
      return true;
    }

    return false;
  }

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

  // ================= GET PROFILE =================
  static Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("TOKEN NULL");
      return null;
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/auth/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // ⚠️ HARUS PERSIS
      },
    );

    print("PROFILE STATUS: ${response.statusCode}");
    print("PROFILE BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  // ================= LOGOUT =================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, dynamic>?> predictWayang(File image) async {
    final uri = Uri.parse("$baseUrl/predict-wayang");

    final request = http.MultipartRequest("POST", uri);
    request.files.add(
      await http.MultipartFile.fromPath("image", image.path),
    );

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(resBody);
    } else {
      return {
        "prediksi": "Gagal",
        "confidence": "-",
        "deskripsi": "Prediksi gagal dilakukan"
      };
    }
  }
}
