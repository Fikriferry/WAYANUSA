import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:wayanusa/pages/videopage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User flow: buka video → search → pilih video', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: VideoPage(
          disablePlayer: true,
          fetchVideosFn: () async => [
            {
              "title": "Wayang Kulit Epik",
              "youtube_id": "abc123",
              "thumbnail": ""
            },
            {
              "title": "Lakon Bima Suci",
              "youtube_id": "def456",
              "thumbnail": ""
            },
          ],
        ),
      ),
    );

    // ⏳ Tunggu frame pertama + fetch async
    await tester.pump();  
    await tester.pump(const Duration(seconds: 1));

    /// ===============================
    /// 1️⃣ Pastikan list video tampil
    /// ===============================
    expect(find.text("Wayang Kulit Epik"), findsOneWidget);
    expect(find.text("Lakon Bima Suci"), findsOneWidget);

    /// ===============================
    /// 2️⃣ Cari video
    /// ===============================
    final searchField = find.widgetWithText(TextField, "Cari video...");
    await tester.enterText(searchField, "Bima");
    await tester.pump();

    expect(find.text("Lakon Bima Suci"), findsOneWidget);
    expect(find.text("Wayang Kulit Epik"), findsNothing);

    /// ===============================
    /// 3️⃣ Tap video
    /// ===============================
    await tester.tap(find.text("Lakon Bima Suci"));
    await tester.pump();
  });
}