import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wayanusa/pages/article_list_page.dart';

class MockFetcher extends Mock {
  Future<List<dynamic>> call();
}

void main() {
  late MockFetcher mockFetcher;

  final fakeArticles = [
    {
      'id': 1,
      'title': 'Judul Artikel Test',
      'content_preview': 'Preview artikel',
      'thumbnail': null,
    }
  ];

  setUp(() {
    mockFetcher = MockFetcher();
  });

  /// ===============================
  /// 1. TEST DATA MUNCUL
  /// ===============================
  testWidgets(
    'Menampilkan judul artikel setelah fetch',
    (WidgetTester tester) async {
      when(() => mockFetcher()).thenAnswer((_) async => fakeArticles);

      await tester.pumpWidget(
        MaterialApp(
          home: ArticleListPage(fetcher: mockFetcher),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Judul Artikel Test'), findsOneWidget);
      expect(find.text('Preview artikel'), findsOneWidget);
    },
  );

  /// ===============================
  /// 2. TEST FETCHER DIPANGGIL
  /// ===============================
  testWidgets(
    'Fetcher dipanggil satu kali',
    (WidgetTester tester) async {
      when(() => mockFetcher()).thenAnswer((_) async => fakeArticles);

      await tester.pumpWidget(
        MaterialApp(
          home: ArticleListPage(fetcher: mockFetcher),
        ),
      );

      await tester.pumpAndSettle();

      verify(() => mockFetcher()).called(1);
    },
  );

  /// ===============================
  /// 3. TEST LOADING & DATA
  /// ===============================
  testWidgets(
    'ArticleListPage fetch data dan menampilkan artikel',
    (WidgetTester tester) async {
      when(() => mockFetcher()).thenAnswer(
        (_) async => [
          {
            'id': 1,
            'title': 'Judul Artikel Test',
            'content_preview': 'Preview artikel',
            'thumbnail': null,
          }
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ArticleListPage(fetcher: mockFetcher),
        ),
      );

      // Loading muncul
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Tunggu fetch selesai
      await tester.pumpAndSettle();

      // Data tampil
      expect(find.text('Judul Artikel Test'), findsOneWidget);

      // Fetcher terpanggil
      verify(() => mockFetcher()).called(1);
    },
  );
}