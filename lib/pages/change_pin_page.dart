import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/models/user_model.dart';

class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key});

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitChangePin() async {
    if (_formKey.currentState!.validate()) {
      final user = ModalRoute.of(context)!.settings.arguments as User;

      try {
        bool updated = await DatabaseHelper().updatePin(
          user.id,
          _oldPinController.text,
          _newPinController.text,
        );

        if (!mounted) return;

        if (updated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN berhasil diubah!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN lama salah!'), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
         if (!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldPinController,
                decoration: const InputDecoration(labelText: 'PIN Lama'),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                validator: (v) => (v?.length ?? 0) < 6 ? 'PIN harus 6 digit' : null,
              ),
              TextFormField(
                controller: _newPinController,
                decoration: const InputDecoration(labelText: 'PIN Baru'),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                validator: (v) => (v?.length ?? 0) < 6 ? 'PIN harus 6 digit' : null,
              ),
              TextFormField(
                controller: _confirmPinController,
                decoration: const InputDecoration(labelText: 'Konfirmasi PIN Baru'),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                validator: (v) {
                  if ((v?.length ?? 0) < 6) return 'PIN harus 6 digit';
                  if (v != _newPinController.text) return 'PIN tidak cocok';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitChangePin,
                child: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}