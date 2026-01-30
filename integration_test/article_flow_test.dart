import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wayanusa/pages/article_list_page.dart';
import 'package:wayanusa/pages/article_detail_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User flow: buka artikel → lihat detail', (tester) async {
    // 🔹 Fake data biar ga tergantung API
    Future<List<dynamic>> fakeFetcher() async {
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        {
          'id': 1,
          'title': 'Judul Artikel Test',
          'content_preview': 'Preview artikel budaya',
          'content': '<p>Isi lengkap artikel</p>',
          'thumbnail': null,
        }
      ];
    }

    await tester.pumpWidget(
      MaterialApp(
        home: ArticleListPage(fetcher: fakeFetcher),
      ),
    );

    // ⏳ Tunggu loading selesai
    await tester.pumpAndSettle();

    // ===============================
    // 1️⃣ Pastikan artikel muncul
    // ===============================
    expect(find.text('Judul Artikel Test'), findsOneWidget);
    expect(find.text('Preview artikel budaya'), findsOneWidget);

    // ===============================
    // 2️⃣ Tap artikel
    // ===============================
    await tester.tap(find.text('Judul Artikel Test'));
    await tester.pumpAndSettle();

    // ===============================
    // 3️⃣ Pastikan pindah ke detail
    // ===============================
    expect(find.byType(ArticleDetailPage), findsOneWidget);
  });
}