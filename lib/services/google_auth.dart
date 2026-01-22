import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Ganti ke SharedPreferences

class GoogleAuthService {
  // 1. Inisialisasi Google Sign In
  static final _googleSignIn = GoogleSignIn(
    serverClientId:
        '822370255599-g2spa8cqjh2gsjhnea85c09ncardlng1.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  /// Fungsi Login Utama
  static Future<bool> loginWithGoogle() async {
    try {
      print("1. Membuka dialog pemilihan akun Google...");
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        print("Batal: Pengguna menutup pop-up login.");
        return false;
      }
      print("2. Akun dipilih: ${account.email}");

      final GoogleSignInAuthentication auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        print("Error: idToken kosong.");
        return false;
      }

      // 3. Mengirim ke Server Flask
      print("3. Menghubungi server Flask...");
      final response = await http
          .post(
            Uri.parse(
              "https://monoclinic-superboldly-tobi.ngrok-free.dev/api/auth/google/android",
            ),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"idToken": idToken}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // 4. SIMPAN KE SHARED PREFERENCES (Sesuai dengan ApiService)
        if (data.containsKey('access_token')) {
          final prefs = await SharedPreferences.getInstance();
          // Gunakan kunci 'token' agar sama dengan ApiService.dart
          await prefs.setString('token', data['access_token']);

          print(
            "✅ Login Google Berhasil! Token disimpan di SharedPreferences.",
          );
          return true;
        }
      } else {
        print("❌ Server Error ${response.statusCode}: ${response.body}");
      }

      return false;
    } catch (e) {
      print("⚠️ Error GoogleAuthService: $e");
      return false;
    }
  }

  /// Fungsi Logout
  static Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
      print("Google session disconnected.");
    } catch (e) {
      print("Google logout error: $e");
    }
  }
}
