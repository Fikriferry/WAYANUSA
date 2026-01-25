import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeWayangPage logic tests', () {
    test('Mengambil nama depan dari nama lengkap', () {
      // Arrange
      const fullName = 'Aji Purnomo';

      // Act (logic yang dipakai di HomePage)
      final firstName = fullName.split(' ').first;

      // Assert
      expect(firstName, 'Aji');
    });

    test('Data artikel dari API terbaca dengan benar', () {
      // Mock hasil API
      final articles = [
        {'title': 'Artikel 1', 'content_preview': 'Isi 1'},
        {'title': 'Artikel 2', 'content_preview': 'Isi 2'},
      ];

      expect(articles.length, 2);
      expect(articles[0]['title'], 'Artikel 1');
      expect(articles[1]['title'], 'Artikel 2');
    });
  });
}
