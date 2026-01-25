import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayanusa/pages/register_page.dart';

void main() {
  testWidgets('RegisterPage tampil dengan field lengkap', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Alamat Email'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Konfirmasi Sandi'), findsOneWidget);
    expect(find.text('DAFTAR SEKARANG'), findsOneWidget);
  });
  testWidgets('Klik daftar tanpa isi data → muncul SnackBar error', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    // Tunggu animasi selesai
    await tester.pumpAndSettle();

    // Cari tombol berdasarkan text
    final daftarButton = find.text('DAFTAR SEKARANG');

    // ⬇️ SCROLL sampai tombol terlihat
    await tester.ensureVisible(daftarButton);

    // Tap tombol
    await tester.tap(daftarButton);

    // Tunggu SnackBar muncul
    await tester.pumpAndSettle();

    // Validasi SnackBar
    expect(find.textContaining('isi semua datanya'), findsOneWidget);
  });

  testWidgets('Isi form register', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    await tester.enterText(find.byType(TextField).at(0), 'Boyy');
    await tester.enterText(find.byType(TextField).at(1), 'boyy@mail.com');
    await tester.enterText(find.byType(TextField).at(2), '123456');
    await tester.enterText(find.byType(TextField).at(3), '123456');

    await tester.tap(find.text('DAFTAR SEKARANG'));
    await tester.pump();
  });
}
