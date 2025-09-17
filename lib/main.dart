// lib/main.dart
import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/pages/dashboard_page.dart';
import 'package:mobile_programming_uts/pages/login_page.dart';
import 'package:mobile_programming_uts/pages/register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Banking UTS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Rute awal aplikasi
      initialRoute: '/',
      // Daftar semua rute/halaman yang ada di aplikasi
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}