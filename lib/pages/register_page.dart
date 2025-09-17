// lib/pages/register_page.dart

import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Mobile Banking'),
      ),
      body: const Center(
        child: Text('Ini Halaman Register'),
      ),
    );
  }
}