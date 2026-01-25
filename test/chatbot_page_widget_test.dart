import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:wayanusa/pages/chatbotpage.dart';

void main() {
  group('ChatbotPage Widget Test', () {
    testWidgets('Halaman ChatbotPage tampil', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(const MaterialApp(home: ChatbotPage()));

        // ❗ JANGAN pumpAndSettle
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(ChatbotPage), findsOneWidget);
        expect(find.text('Cepot AI'), findsOneWidget);
        expect(find.byIcon(Icons.send_rounded), findsOneWidget);
      });
    });

    testWidgets('Quick replies tampil saat mode Wayanusa', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(const MaterialApp(home: ChatbotPage()));

        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Apa itu Wayang?'), findsOneWidget);
        expect(find.text('Tokoh Pandawa'), findsOneWidget);
      });
    });

    testWidgets('Switch mode bisa di-tap', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(const MaterialApp(home: ChatbotPage()));

        await tester.pump(const Duration(milliseconds: 300));

        final switchFinder = find.byType(Switch);
        expect(switchFinder, findsOneWidget);

        await tester.tap(switchFinder);
        await tester.pump(const Duration(milliseconds: 300));
      });
    });
  });
}
