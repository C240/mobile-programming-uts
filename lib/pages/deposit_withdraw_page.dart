import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_programming_uts/utils/format.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/models/account_model.dart';

class DepositWithdrawPage extends StatefulWidget {
  final Account userAccount;

  const DepositWithdrawPage({super.key, required this.userAccount});

  @override
  State<DepositWithdrawPage> createState() => _DepositWithdrawPageState();
}

class RupiahInputFormatter extends TextInputFormatter {
  final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) {
      return const TextEditingValue(
          text: '', selection: TextSelection.collapsed(offset: 0));
    }
    final number = int.parse(text);
    final formatted = _formatter.format(number);
    return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length));
  }
}

class _DepositWithdrawPageState extends State<DepositWithdrawPage> {
  final db = DatabaseHelper();

  Future<void> performDeposit(double amount, String pin) async {
    bool isPinValid =
        await db.verifyPin(widget.userAccount.userId, pin);
    if (!mounted) return;

    if (!isPinValid) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN salah')));
      return;
    }

    double newBalance = widget.userAccount.balance + amount;
    await db.updateAccountBalance(
        widget.userAccount.accountNumber, newBalance);
    await db.insertTransaction(
      fromAccount: 'Deposit',
      toAccountNumber: widget.userAccount.accountNumber,
      amount: amount,
      description: 'Deposit',
      category: 'Deposit',
    );

    if (!mounted) return;
    setState(() {
      widget.userAccount.balance = newBalance;
    });

    showSuccessDialog('Deposit Berhasil!', amount);
  }

  Future<void> performWithdraw(double amount, String pin) async {
    bool isPinValid =
        await db.verifyPin(widget.userAccount.userId, pin);
    if (!mounted) return;

    if (!isPinValid) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN salah')));
      return;
    }

    if (widget.userAccount.balance < amount) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saldo tidak mencukupi')));
      return;
    }

    double newBalance = widget.userAccount.balance - amount;
    await db.updateAccountBalance(
        widget.userAccount.accountNumber, newBalance);
    await db.insertTransaction(
      fromAccount: widget.userAccount.accountNumber,
      toAccountNumber: 'Withdraw',
      amount: amount,
      description: 'Withdraw',
      category: 'Withdraw',
    );

    if (!mounted) return;
    setState(() {
      widget.userAccount.balance = newBalance;
    });

    showSuccessDialog('Withdraw Berhasil!', amount);
  }

  void showAmountDialog(bool isDeposit) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isDeposit ? 'Deposit' : 'Withdraw'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [RupiahInputFormatter()],
          decoration: const InputDecoration(
            labelText: 'Jumlah',
            prefixIcon: Icon(Icons.attach_money),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () {
                final amount =
                    parseRupiahToDouble(amountController.text);
                if (amount > 0) {
                  if (mounted) Navigator.pop(context);
                  showPinDialog(isDeposit, amount);
                }
              },
              child: const Text('Lanjut')),
        ],
      ),
    );
  }

  void showPinDialog(bool isDeposit, double amount) {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Masukkan PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'PIN',
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () {
                final pin = pinController.text;
                if (pin.length == 6) {
                  if (mounted) Navigator.pop(context);
                  if (isDeposit) {
                    performDeposit(amount, pin);
                  } else {
                    performWithdraw(amount, pin);
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN harus 6 digit')),
                    );
                  }
                }
              },
              child: const Text('Konfirmasi')),
        ],
      ),
    );
  }

  void showSuccessDialog(String title, double amount) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Jumlah: ${formatRupiah(amount)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Akun Anda'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nomor Rekening',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(widget.userAccount.accountNumber,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Saldo Anda',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(formatRupiah(widget.userAccount.balance),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => showAmountDialog(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1775C2),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.arrow_downward,
                            size: 36, color: Colors.white),
                        SizedBox(height: 8),
                        Text('Deposit',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => showAmountDialog(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1775C2),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.arrow_upward,
                            size: 36, color: Colors.white),
                        SizedBox(height: 8),
                        Text('Withdraw',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
