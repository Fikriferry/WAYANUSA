import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:wayanusa/pages/homepage.dart';

void main() {
  group('HomeWayangPage widget tests', () {
    testWidgets('Halaman HomeWayangPage tampil', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(home: HomeWayangPage(disableApi: true)),
        );

        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(HomeWayangPage), findsOneWidget);
      });
    });

    testWidgets('Tombol ChatBot ada', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(home: HomeWayangPage(disableApi: true)),
        );

        // ❌ JANGAN pumpAndSettle
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      });
    });
  });
}
