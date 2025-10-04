import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/widgets/auth_layout.dart';
import 'package:mobile_programming_uts/widgets/auth_text_field.dart';
import 'package:mobile_programming_uts/widgets/auth_primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await DatabaseHelper().registerUser(
          _usernameController.text,
          _passwordController.text,
          _pinController.text,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
        );

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal registrasi: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(12);
    return Scaffold(
      body: AuthLayout(
        title: 'Daftar',
        subtitle: 'Buat akun Mobile Banking',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.person,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'Username tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscure: true,
                toggleObscure: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _confirmPasswordController,
                label: 'Konfirmasi Password',
                icon: Icons.lock_outline,
                obscure: true,
                toggleObscure: true,
                textInputAction: TextInputAction.next,
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'Konfirmasi password tidak boleh kosong';
                  }
                  if(value != _passwordController.text){
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _pinController,
                label: 'PIN (6 Digit)',
                icon: Icons.pin,
                keyboardType: TextInputType.number,
                obscure: true,
                maxLength: 6,
                validator:(value) {
                  if(value == null || value.length < 6) {
                    return 'PIN harus 6 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AuthPrimaryButton(text: 'Daftar', onPressed: _register),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Sudah punya akun? Masuk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}