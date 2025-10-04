// lib/pages/transfer_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/models/account_model.dart';
import 'package:mobile_programming_uts/models/transaction_model.dart';
import 'package:mobile_programming_uts/models/user_model.dart';
import 'package:mobile_programming_uts/utils/format.dart';
import 'package:mobile_programming_uts/utils/rupiah_input_formatter.dart';
import 'package:mobile_programming_uts/widgets/confirm_transfer_sheet.dart';

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

  String? _recipientName;
  bool _checkingRecipient = false;

  // Pemilihan dompet sumber
  List<Account> _userAccounts = [];
  Account? _selectedFromAccount;
  bool _loadingAccounts = false;
  bool _initialized = false;

  // Semua fungsi logika ( _validateAndShowPinDialog, _showPinDialog, _performTransfer, _showError )
  // tetap sama seperti sebelumnya, tidak ada perubahan.

  // ... (Salin semua fungsi logika dari file Anda sebelumnya ke sini)
  void _validateAndShowPinDialog() {
    // Pastikan form valid
    if (_formKey.currentState!.validate()) {
      final amountString = _amountController.text;
      final amount = parseRupiahToDouble(amountString);
      final toAcc = _toAccountController.text.trim();
      final fromAcc = (_selectedFromAccount ?? (ModalRoute.of(context)!.settings.arguments as Account)).accountNumber;

      // Pastikan jumlah adalah angka yang valid
      if (amount <= 0) {
        _showError('Format jumlah transfer tidak valid.');
        return;
      }

      // Cegah transfer ke akun sendiri
      if (toAcc == fromAcc) {
        _showError('Tidak dapat transfer ke akun sendiri.');
        return;
      }
      
      // Jika semua valid, tampilkan sheet konfirmasi terlebih dahulu
      _showConfirmSheet(amount);
    }
  }

  void _showConfirmSheet(double amount) {
    final from = _selectedFromAccount ?? (ModalRoute.of(context)!.settings.arguments as Account);
    final toAcc = _toAccountController.text.trim();
    final desc = _descriptionController.text.trim();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ConfirmTransferSheet(
          fromAccount: from,
          toAccountNumber: toAcc,
          amount: amount,
          recipientName: _recipientName,
          description: desc,
          onCancel: () => Navigator.pop(context),
          onConfirm: () {
            Navigator.pop(context);
            _showPinDialog(amount);
          },
        );
      },
    );
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
    // Gunakan akun yang dipilih sebagai sumber
    final selected = _selectedFromAccount ?? (ModalRoute.of(context)!.settings.arguments as Account);
    // Validasi tambahan untuk keamanan
    if (_toAccountController.text.trim() == selected.accountNumber) {
      _showError('Tidak dapat transfer ke akun sendiri.');
      return;
    }
    final user = await DatabaseHelper().getUserById(selected.userId);

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
        selected.accountNumber,
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

  Future<void> _lookupRecipient(String accountNumber) async {
    setState(() {
      _checkingRecipient = true;
      _recipientName = null;
    });
    final user = await DatabaseHelper().getUserByAccountNumber(accountNumber);
    if (!mounted) return;
    setState(() {
      _checkingRecipient = false;
      _recipientName = user?.username;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final fromAccountArg = ModalRoute.of(context)!.settings.arguments as Account;
      _selectedFromAccount = fromAccountArg;
      _loadUserAccounts(fromAccountArg.userId);
    }
  }

  Future<void> _loadUserAccounts(int userId) async {
    setState(() {
      _loadingAccounts = true;
    });
    final accounts = await DatabaseHelper().getAccounts(userId);
    if (!mounted) return;
    setState(() {
      _userAccounts = accounts.map((map) => Account.fromMap(map)).toList();
      if (_selectedFromAccount != null) {
        final match = _userAccounts.firstWhere(
          (a) => a.accountNumber == _selectedFromAccount!.accountNumber,
          orElse: () => _userAccounts.isNotEmpty ? _userAccounts.first : _selectedFromAccount!,
        );
        _selectedFromAccount = match;
      } else if (_userAccounts.isNotEmpty) {
        _selectedFromAccount = _userAccounts.first;
      }
      _loadingAccounts = false;
    });
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
                  'Dari Dompet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Pilih dompet sumber',
                  ),
                  child: _loadingAccounts
                      ? const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Memuat dompet...'),
                          ],
                        )
                      : (_userAccounts.isEmpty
                          ? const Text('Tidak ada dompet tersedia')
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<Account>(
                                isExpanded: true,
                                value: _userAccounts.any((a) => a.accountNumber == _selectedFromAccount?.accountNumber)
                                    ? _selectedFromAccount
                                    : null,
                items: _userAccounts
                    .map(
                      (a) => DropdownMenuItem<Account>(
                        value: a,
                        child: Text('${a.accountNumber} • ${formatRupiah(a.balance)}'),
                      ),
                    )
                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedFromAccount = val;
                                  });
                                },
                              ),
                            )),
                ),
                const SizedBox(height: 24),
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
                  onChanged: (value) {
                    // Lakukan pencarian nama penerima ketika panjang input memadai
                    if (value.trim().length >= 10) {
                      _lookupRecipient(value.trim());
                    } else {
                      setState(() {
                        _recipientName = null;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor rekening tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                if (_checkingRecipient)
                  const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Memeriksa penerima...'),
                    ],
                  ),
                if (!_checkingRecipient && _recipientName != null)
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Text('Nama penerima: ${_recipientName!}'),
                    ],
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
                  keyboardType: TextInputType.number,
                  inputFormatters: [RupiahInputFormatter()],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah transfer tidak boleh kosong';
                    }
                    final amount = parseRupiahToDouble(value);
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