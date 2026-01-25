class RegisterValidator {
  static String? validate({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return "Waduh, isi semua datanya dulu ya!";
    }
    if (password != confirmPassword) {
      return "Konfirmasi kata sandinya beda euy!";
    }
    return null; // valid
  }
}
