import 'package:flutter_test/flutter_test.dart';
import 'package:wayanusa/utils/register_validator.dart';

void main() {
  group('Register Validator Test', () {
    test('Gagal jika field kosong', () {
      final result = RegisterValidator.validate(
        name: '',
        email: 'test@mail.com',
        password: '123456',
        confirmPassword: '123456',
      );

      expect(result, isNotNull);
    });

    test('Gagal jika password tidak sama', () {
      final result = RegisterValidator.validate(
        name: 'Boyy',
        email: 'boyy@mail.com',
        password: '123456',
        confirmPassword: '654321',
      );

      expect(result, equals("Konfirmasi kata sandinya beda euy!"));
    });

    test('Berhasil jika semua valid', () {
      final result = RegisterValidator.validate(
        name: 'Boyy',
        email: 'boyy@mail.com',
        password: '123456',
        confirmPassword: '123456',
      );

      expect(result, isNull);
    });
  });
}
