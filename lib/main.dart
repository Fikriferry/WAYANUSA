import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/homepage.dart';
import 'pages/chatbotpage.dart';
import 'pages/videopage.dart';
import 'pages/quiz_page.dart';
import 'pages/cari_dalang_page.dart';
import 'pages/edit_profile_page.dart';
import 'pages/profile_page.dart';
import 'pages/citra_wayang.dart';
import 'pages/sejarah_wayang_page.dart';
import 'pages/sejarah_detail_page.dart';
import 'pages/simulasi_dalang_page.dart';
import 'pages/notification_settings_page.dart';
import 'pages/help_support_page.dart';
import 'pages/about_app_page.dart';
import 'pages/smart_wayang_page.dart';
import 'pages/article_list_page.dart';

void main() {
  runApp(const WayanusaApp());
}

class WayanusaApp extends StatelessWidget {
  const WayanusaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wayanusa',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB6783D)),
        useMaterial3: true,
      ),

      //  halaman pertama tetap login
      initialRoute: '/login',

      //  semua route
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        // route halaman utama setelah login
        '/home': (context) => const HomeWayangPage(),

        // route halaman chatbot
        '/chatbot': (context) => const ChatbotPage(),

        // route halaman video
        '/video': (context) => const VideoPage(),

        // route halaman quiz
        '/tes_singkat': (context) => const QuizPage(),

        '/cari_dalang': (context) => const CariDalangPage(),

        // '/edit_profile': (context) => const EditProfilePage(),

        '/profile': (context) => const ProfilePage(),

        '/pengenalan_wayang': (context) => const PengenalanWayangPage(),

        '/sejarah_wayang': (context) => const SejarahWayangPage(),

        '/sejarah_detail': (context) => const ArtikelDetailPage(),

        '/simulasi_dalang': (context) => const SimulasiDalangPage(),

        '/notification_settings': (context) => const NotificationSettingsPage(),

        '/help_support': (context) => const HelpSupportPage(),

        '/about_app': (context) => const AboutAppPage(),

        '/smart_wayang': (context) => const SmartWayangPage(),

        '/article_list': (context) => const ArticleListPage(),
      },
    );
  }
}
