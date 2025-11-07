import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/homepage.dart';       
import 'pages/chatbotpage.dart';    
import 'pages/videopage.dart';

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
        '/chatbot': (context) => const ChatBotPage(),

        // route halaman video
        '/video': (context) => const VideoPage(),
      },
    );
  }
}