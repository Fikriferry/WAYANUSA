import 'package:flutter_test/flutter_test.dart';

String getFormattedTime(DateTime now) {
  return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
}

void main() {
  group('Chatbot Logic Unit Test', () {
    test('Format waktu HH:mm benar', () {
      final time = DateTime(2025, 1, 1, 9, 5);
      final result = getFormattedTime(time);

      expect(result, '09:05');
    });

    test('Format waktu jam 2 digit', () {
      final time = DateTime(2025, 1, 1, 14, 45);
      final result = getFormattedTime(time);

      expect(result, '14:45');
    });
  });
}
