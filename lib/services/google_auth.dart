import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GoogleAuthService {
  static final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  static final _storage = FlutterSecureStorage();

  static Future<bool> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) return false;

      final GoogleSignInAuthentication auth = await account.authentication;

      final idToken = auth.idToken;

      if (idToken == null) return false;

      /// 🔗 Kirim ke Flask
      final res = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/auth/google/android"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idToken": idToken}),
      );

      print("Backend response status: ${res.statusCode}");
      print("Backend response body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        /// 🔐 Simpan JWT
        await _storage.write(key: "jwt_token", value: data["access_token"]);

        return true;
      }

      return false;
    } catch (e) {
      print("Google login error: $e");
      return false;
    }
  }

  static Future<void> logout() async {
    await _googleSignIn.signOut();
    await _storage.delete(key: "jwt_token");
  }
}
