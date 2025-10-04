import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/models/user_model.dart';
import 'package:mobile_programming_uts/widgets/auth_layout.dart';
import 'package:mobile_programming_uts/widgets/auth_text_field.dart';
import 'package:mobile_programming_uts/widgets/auth_primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      var userMap = await DatabaseHelper().loginUser(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;
      if (userMap != null) {
        User loggedInUser = User.fromMap(userMap);
        Navigator.pushReplacementNamed(
          context,
          '/main',
          arguments: loggedInUser,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login gagal! Periksa username dan password.')),
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
        title: 'Masuk',
        subtitle: 'Login Mobile Banking',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
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
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AuthPrimaryButton(text: 'Login', onPressed: _login),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Belum punya akun? Daftar di sini'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}