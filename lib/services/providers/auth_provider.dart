import 'package:flutter/material.dart';
import '../google_auth.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> loginWithGoogle() async {
    _isLoggedIn = await GoogleAuthService.loginWithGoogle();
    notifyListeners();
  }

  void logout() {
    GoogleAuthService.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}
