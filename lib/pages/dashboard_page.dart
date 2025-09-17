// lib/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/models/user_model.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Terima objek User yang dikirim dari halaman login
    final user = ModalRoute.of(context)!.settings.arguments as User;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        // Tampilkan pesan selamat datang dengan username
        child: Text(
          'Selamat Datang, ${user.username}!',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}