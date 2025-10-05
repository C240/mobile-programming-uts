import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/models/account_model.dart';
import 'package:mobile_programming_uts/models/transaction_model.dart';
import 'package:mobile_programming_uts/utils/format.dart';
import 'package:mobile_programming_uts/utils/rupiah_input_formatter.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Account> _userAccounts = [];
  Account? _selectedAccount;
  bool _loadingAccounts = false;
  bool _initialized = false;
  
  static const List<String> _paymentMethods = [
    'Bank Transfer',
    'Credit Card',
    'Debit Card',
    'E-Wallet',
    'Virtual Account',
  ];
  String? _selectedPaymentMethod = 'Bank Transfer';

  void _validateAndShowPinDialog() {
    if (_formKey.currentState!.validate()) {
      final amountString = _amountController.text;
      final amount = parseRupiahToDouble(amountString);
      
      if (amount <= 0) {
        _showError('Jumlah top-up harus lebih dari 0.');
        return;
      }
      
      if (amount < 10000) {
        _showError('Minimum top-up adalah Rp 10.000.');
        return;
      }
      
      _showConfirmDialog(amount);
    }
  }

  void _showConfirmDialog(double amount) {
    final account = _selectedAccount ?? (ModalRoute.of(context)!.settings.arguments as Account);
    final description = _descriptionController.text.trim().isEmpty 
        ? 'Top-up via $_selectedPaymentMethod' 
        : _descriptionController.text.trim();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Top-Up'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rekening: ${account.accountNumber}'),
              const SizedBox(height: 8),
              Text('Jumlah: ${formatRupiah(amount)}'),
              const SizedBox(height: 8),
              Text('Metode: $_selectedPaymentMethod'),
              const SizedBox(height: 8),
              Text('Deskripsi: $description'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Saldo akan bertambah sebesar ${formatRupiah(amount)}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showPinDialog(amount);
              },
              child: const Text('Lanjutkan'),
            ),
          ],
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
                _performTopUp(amount);
              },
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );
  }

  void _performTopUp(double amount) async {
    final account = _selectedAccount ?? (ModalRoute.of(context)!.settings.arguments as Account);
    final user = await DatabaseHelper().getUserById(account.userId);

    if (user == null) {
      _showError('Gagal memverifikasi pengguna.');
      return;
    }

    bool isPinValid = await DatabaseHelper().verifyPin(
      user.id,
      _pinController.text,
    );

    if (!mounted) return;

    if (!isPinValid) {
      _showError('PIN yang Anda masukkan salah.');
      _pinController.clear();
      return;
    }

    Navigator.pop(context);

    final description = _descriptionController.text.trim().isEmpty 
        ? 'Top-up via $_selectedPaymentMethod' 
        : _descriptionController.text.trim();

    try {
      int transactionId = await DatabaseHelper().topUp(
        account.accountNumber,
        amount,
        _selectedPaymentMethod!,
        description,
      );

      var newTransactionMap = await DatabaseHelper().getTransactionById(transactionId);
      if (newTransactionMap != null) {
        final newTransaction = Transaction.fromMap(newTransactionMap);
        if (!mounted) return;
        
        // Show success message
        _showSuccessDialog(amount);
        
        // Navigate to transaction detail
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

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 8),
              const Text('Top-Up Berhasil'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Top-up sebesar ${formatRupiah(amount)} berhasil dilakukan.'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Saldo Anda telah bertambah',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to home
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      const int currentUserId = 1;
      _loadUserAccounts(currentUserId);
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
      if (_userAccounts.isNotEmpty) {
        _selectedAccount = _userAccounts.first;
      }
      _loadingAccounts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top-Up Saldo')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Selection
                Text(
                  'Pilih Rekening',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Pilih rekening tujuan',
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
                            Text('Memuat rekening...'),
                          ],
                        )
                      : (_userAccounts.isEmpty
                            ? const Text('Tidak ada rekening tersedia')
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<Account>(
                                  isExpanded: true,
                                  value: _selectedAccount,
                                  items: _userAccounts
                                      .map(
                                        (a) => DropdownMenuItem<Account>(
                                          value: a,
                                          child: Text(
                                            '${a.accountNumber} • ${formatRupiah(a.balance)}',
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedAccount = val;
                                    });
                                  },
                                ),
                              )),
                ),
                const SizedBox(height: 24),
                
                // Amount Input
                Text(
                  'Jumlah Top-Up',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Top-Up',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan jumlah top-up',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [RupiahInputFormatter()],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah top-up tidak boleh kosong';
                    }
                    final amount = parseRupiahToDouble(value);
                    if (amount <= 0) {
                      return 'Jumlah top-up harus lebih dari 0';
                    }
                    if (amount < 10000) {
                      return 'Minimum top-up adalah Rp 10.000';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Payment Method
                Text(
                  'Metode Pembayaran',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPaymentMethod,
                  items: _paymentMethods
                      .map(
                        (method) => DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedPaymentMethod = val;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Pilih metode pembayaran',
                    prefixIcon: Icon(Icons.payment),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Description
                Text(
                  'Deskripsi (Opsional)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    prefixIcon: Icon(Icons.note_add),
                    border: OutlineInputBorder(),
                    hintText: 'Contoh: Top-up untuk kebutuhan bulanan',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 32),
                
                // Quick Amount Buttons
                Text(
                  'Jumlah Cepat',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickAmountButton('50K', 50000),
                    _buildQuickAmountButton('100K', 100000),
                    _buildQuickAmountButton('250K', 250000),
                    _buildQuickAmountButton('500K', 500000),
                    _buildQuickAmountButton('1M', 1000000),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Submit Button
                ElevatedButton(
                  onPressed: _validateAndShowPinDialog,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Top-Up Sekarang'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(String label, double amount) {
    return OutlinedButton(
      onPressed: () {
        _amountController.text = formatRupiah(amount);
      },
      child: Text(label),
    );
  }
}
