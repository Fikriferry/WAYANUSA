import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:wayanusa/pages/cari_dalang_page.dart';
import 'package:wayanusa/pages/detail_dalang_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User flow: cari dalang → lihat detail', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CariDalangPage(
          getDalangFn: () async => [
            {
              "id": 1,
              "nama": "Dalang Cepot",
              "alamat": "Bandung",
              "foto": "",
              "latitude": 0.0,
              "longitude": 0.0,
            }
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Pastikan list muncul
    expect(find.text("Dalang Cepot"), findsOneWidget);

    // Ketik di search
    await tester.enterText(find.byType(TextField), "Cepot");
    await tester.pumpAndSettle();

    // Tap card
    await tester.tap(find.text("Dalang Cepot"));
    await tester.pumpAndSettle();

    // Pastikan masuk halaman detail
    expect(find.byType(DetailDalangPage), findsOneWidget);
  });
}