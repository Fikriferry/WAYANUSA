import 'package:flutter_test/flutter_test.dart';

/// Fake API Service
class FakeApiService {
  static Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return email == 'test@mail.com' && password == '123456';
  }
}

void main() {
  test('Login berhasil jika email & password benar', () async {
    final result = await FakeApiService.login('test@mail.com', '123456');

    expect(result, true);
  });

  test('Login gagal jika password salah', () async {
    final result = await FakeApiService.login('test@mail.com', 'salah');

    expect(result, false);
  });

  test('Login gagal jika email salah', () async {
    final result = await FakeApiService.login('salah@mail.com', '123456');

    expect(result, false);
  });
}
