// lib/pages/login_page.dart

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Mobile Banking'),
      ),
      body: const Center(
        child: Text('Ini Halaman Login'),
      ),
    );
  }
}