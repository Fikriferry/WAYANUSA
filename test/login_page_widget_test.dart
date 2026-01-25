import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayanusa/pages/login_page.dart';

void main() {
  testWidgets('LoginPage tampil dengan field & tombol utama', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Selamat Datang!'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('MASUK KE WAYANUSA'), findsOneWidget);
    expect(find.text('Masuk dengan Google'), findsOneWidget);
  });

  testWidgets('Menampilkan snackbar jika email/password kosong', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Biarkan animasi awal jalan dikit
    await tester.pump(const Duration(milliseconds: 1200));

    // Klik tombol login tanpa isi field
    await tester.tap(find.text('MASUK KE WAYANUSA'));

    // Biarkan SnackBar muncul
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('email & password'), findsOneWidget);
  });
}
