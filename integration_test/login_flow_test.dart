import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:wayanusa/pages/login_page.dart';
import 'package:wayanusa/pages/homepage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User flow: login berhasil → masuk homepage', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          disableAnimation: true, // penting!
          loginFn: (email, password) async => true,
        ),
      ),
    );

    expect(find.text("Selamat Datang!"), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('login_email')),
      'user@test.com',
    );
    await tester.enterText(find.byKey(const Key('login_password')), '123456');

    await tester.tap(find.byKey(const Key('login_button')));

    // ❌ jangan pakai pumpAndSettle
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(HomeWayangPage), findsOneWidget);
  });
}
