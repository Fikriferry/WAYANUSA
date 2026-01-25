import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:wayanusa/services/api_service.dart';

/// ===============================
/// MOCK HTTP CLIENT
/// ===============================
class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;

  setUpAll(() {
    // wajib untuk mocktail
    registerFallbackValue(Uri.parse('https://dummy.com'));
  });

  setUp(() {
    mockClient = MockHttpClient();
  });

  /// ===============================
  /// 1. BERHASIL AMBIL DATA
  /// ===============================
  test('getArticles mengembalikan list ketika status success', () async {
    final fakeResponse = {
      "status": "success",
      "data": [
        {
          "id": 1,
          "title": "Artikel Test",
          "content_preview": "Preview artikel",
          "thumbnail": null
        }
      ]
    };

    when(() => mockClient.get(any())).thenAnswer(
      (_) async => http.Response(jsonEncode(fakeResponse), 200),
    );

    final result = await ApiService.getArticles(client: mockClient);

    expect(result, isA<List>());
    expect(result.length, 1);
    expect(result.first['title'], 'Artikel Test');
  });

  /// ===============================
  /// 2. STATUS BUKAN SUCCESS
  /// ===============================
  test('getArticles mengembalikan list kosong jika status bukan success', () async {
    final fakeResponse = {
      "status": "error",
      "data": []
    };

    when(() => mockClient.get(any())).thenAnswer(
      (_) async => http.Response(jsonEncode(fakeResponse), 200),
    );

    final result = await ApiService.getArticles(client: mockClient);

    expect(result, isEmpty);
  });

  /// ===============================
  /// 3. STATUS CODE BUKAN 200
  /// ===============================
  test('getArticles mengembalikan list kosong jika status code != 200', () async {
    when(() => mockClient.get(any())).thenAnswer(
      (_) async => http.Response('Server error', 500),
    );

    final result = await ApiService.getArticles(client: mockClient);

    expect(result, isEmpty);
  });

  /// ===============================
  /// 4. THROW EXCEPTION
  /// ===============================
  test('getArticles mengembalikan list kosong jika terjadi exception', () async {
    when(() => mockClient.get(any())).thenThrow(Exception('No internet'));

    final result = await ApiService.getArticles(client: mockClient);

    expect(result, isEmpty);
  });
}