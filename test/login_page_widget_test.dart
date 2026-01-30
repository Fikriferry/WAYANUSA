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


}
