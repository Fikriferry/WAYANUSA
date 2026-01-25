import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayanusa/pages/profile_page.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ProfilePage tampil dengan data dummy', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        const MaterialApp(home: ProfilePage(isTest: true)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Boyy Testing'), findsOneWidget);
      expect(find.text('boyy@test.com'), findsOneWidget);
      expect(find.text('Akun Saya'), findsOneWidget);
    });
  });

  testWidgets('Dialog logout muncul', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        const MaterialApp(home: ProfilePage(isTest: true)),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Keluar Aplikasi'));
      await tester.pump();

      expect(find.text('Keluar Akun?'), findsOneWidget);
    });
  });
}
