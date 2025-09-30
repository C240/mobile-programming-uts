// lib/pages/transfer_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/models/account_model.dart';
import 'package:mobile_programming_uts/models/transaction_model.dart';
import 'package:mobile_programming_uts/models/user_model.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _toAccountController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Semua fungsi logika ( _validateAndShowPinDialog, _showPinDialog, _performTransfer, _showError )
  // tetap sama seperti sebelumnya, tidak ada perubahan.

  // ... (Salin semua fungsi logika dari file Anda sebelumnya ke sini)
  void _validateAndShowPinDialog() {
    // Pastikan form valid
    if (_formKey.currentState!.validate()) {
      final amountString = _amountController.text;
      final amount = double.tryParse(amountString);

      // Pastikan jumlah adalah angka yang valid
      if (amount == null) {
        _showError('Format jumlah transfer tidak valid.');
        return;
      }
      
      // Jika semua valid, baru tampilkan dialog PIN
      _showPinDialog(amount);
    }
  }

  void _showPinDialog(double amount) {
    _pinController.clear(); 
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Masukkan PIN'),
          content: TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'PIN',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _performTransfer(amount);
              },
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );
  }

  void _performTransfer(double amount) async {
    final fromAccount = ModalRoute.of(context)!.settings.arguments as Account;
    final user = await DatabaseHelper().getUserById(fromAccount.userId);

    if (user == null) {
      _showError('Gagal memverifikasi pengguna.');
      return;
    }

    bool isPinValid = await DatabaseHelper().verifyPin(user.id, _pinController.text);

    if (!mounted) return;

    if (!isPinValid) {
      _showError('PIN yang Anda masukkan salah.');
      _pinController.clear();
      return;
    }

    Navigator.pop(context);

    final toAccountNumber = _toAccountController.text;
    final description = _descriptionController.text;

    try {
      int transactionId = await DatabaseHelper().transfer(
        fromAccount.accountNumber,
        toAccountNumber,
        amount,
        description,
      );

      var newTransactionMap = await DatabaseHelper().getTransactionById(transactionId);
      if (newTransactionMap != null) {
        final newTransaction = Transaction.fromMap(newTransactionMap);
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/transaction_detail',
          arguments: newTransaction,
        );
      }
    } catch (e) {
      _showError(e.toString().replaceAll("Exception: ", ""));
    }
  }

  void _showError(String message) {
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
  }

  // --- KODE UI YANG DIPERBARUI DIMULAI DARI SINI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer'),
      ),
      // Gunakan SingleChildScrollView agar tidak overflow saat keyboard muncul
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kirim Ke',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _toAccountController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Rekening Tujuan',
                    prefixIcon: Icon(Icons.account_balance),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor rekening tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Detail Transfer',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Transfer',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah transfer tidak boleh kosong';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null) {
                      return 'Format jumlah tidak valid';
                    }
                    if (amount <= 0) {
                      return 'Jumlah transfer harus lebih dari 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi (Opsional)',
                    prefixIcon: Icon(Icons.note_add),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _validateAndShowPinDialog,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    textStyle: const TextStyle(fontSize: 18)
                  ),
                  child: const Text('Lanjutkan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}