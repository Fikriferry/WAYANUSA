import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wayanusa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login flow test: email & password', (tester) async {
    // Jalankan aplikasi
    app.main();
    await tester.pumpAndSettle();

    // Cari widget berdasarkan Key
    final emailField = find.byKey(const Key('login_email'));
    final passwordField = find.byKey(const Key('login_password'));
    final loginButton = find.byKey(const Key('login_button'));

    // Pastikan widget ditemukan
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);

    // Input email & password
    await tester.enterText(emailField, 'test@gmail.com');
    await tester.enterText(passwordField, 'password123');

    // Klik tombol login
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verifikasi pindah ke HomePage
    expect(find.text('WAYANUSA'), findsOneWidget);
  });
}
