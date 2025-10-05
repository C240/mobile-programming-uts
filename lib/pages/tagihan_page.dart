import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/models/account_model.dart';
import 'package:mobile_programming_uts/models/transaction_model.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/utils/format.dart';
import 'package:mobile_programming_uts/utils/rupiah_input_formatter.dart';

class TagihanPage extends StatefulWidget {
  final Account account;

  const TagihanPage({super.key, required this.account});

  @override
  State<TagihanPage> createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
  final _amountController = TextEditingController();
  final _paymentNumberController = TextEditingController();
  final _pinController = TextEditingController();

  String? _selectedBill;
  bool _saveFavorite = false;
  double? _favoriteAmount;
  final List<Map<String, dynamic>> _favoriteTransactions = [];

  final List<Map<String, dynamic>> _billTypes = [
    {'name': 'Listrik', 'icon': Icons.flash_on},
    {'name': 'Air', 'icon': Icons.water},
    {'name': 'Internet', 'icon': Icons.wifi},
    {'name': 'Telepon', 'icon': Icons.phone},
    {'name': 'Pajak', 'icon': Icons.receipt_long},
    {'name': 'Asuransi', 'icon': Icons.shield},
    {'name': 'Kabel & TV', 'icon': Icons.tv},
  ];

  void _showPinDialog(double amount) {
    _pinController.clear();
    if (!mounted) return;
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
              onPressed: () {
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                bool isPinValid = await DatabaseHelper().verifyPin(
                  widget.account.userId,
                  _pinController.text,
                );

                if (!mounted) return;

                if (!isPinValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PIN salah'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  _pinController.clear();
                  return;
                }

                if (mounted) Navigator.pop(context);
                await _completePayment(amount);
              },
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completePayment(double amount) async {
    try {
      double newBalance = widget.account.balance - amount;
      await DatabaseHelper().updateAccountBalance(widget.account.accountNumber, newBalance);

      int transactionId = await DatabaseHelper().insertTransaction(
        fromAccount: widget.account.accountNumber,
        toAccountNumber: 'TAGIHAN_${_selectedBill!}',
        amount: amount,
        description: _paymentNumberController.text,
        category: _selectedBill!,
      );

      var transactionMap = await DatabaseHelper().getTransactionById(transactionId);
      if (transactionMap != null && mounted) {
        final transaction = Transaction.fromMap(transactionMap);

        if (_saveFavorite) {
          setState(() {
            _favoriteTransactions.add({
              'name': _selectedBill!,
              'amount': amount,
            });
          });
        }

        setState(() {
          widget.account.balance = newBalance;
        });

        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Pembayaran Berhasil!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text('Jumlah: ${formatRupiah(transaction.amount)}', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Tutup'),
                  )
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }

    if (!mounted) return;
    _amountController.clear();
    _paymentNumberController.clear();
    _pinController.clear();
    setState(() {
      _selectedBill = null;
      _saveFavorite = false;
    });
  }

  void _payBill() {
    final amount = double.tryParse(
          _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    if (_selectedBill == null) return;
    if (amount <= 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah yang valid'), backgroundColor: Colors.red),
      );
      return;
    }

    _showPinDialog(amount);
  }

  Widget _buildBillButton(Map<String, dynamic> bill) {
    return GestureDetector(
      onTap: () {
        if (!mounted) return;
        setState(() {
          _selectedBill = bill['name'];
          _amountController.text =
              (_favoriteAmount != null && bill['name'] == _selectedBill) ? _favoriteAmount!.toStringAsFixed(0) : '';
          _paymentNumberController.clear();
        });
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.blueAccent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(bill['icon'], size: 28, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              bill['name'],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran & Tagihan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedBill == null) ...[
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _billTypes.map((bill) => _buildBillButton(bill)).toList(),
                ),
                const SizedBox(height: 24),
                if (_favoriteTransactions.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Transaksi Favorit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._favoriteTransactions.map((fav) => Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const Icon(Icons.check, color: Colors.green),
                              title: Text(fav['name']),
                              trailing: Text(formatRupiah(fav['amount'] as double)),
                              onTap: () {
                                if (!mounted) return;
                                setState(() {
                                  _selectedBill = fav['name'];
                                  _amountController.text = (fav['amount'] as double).toStringAsFixed(0);
                                });
                              },
                            ),
                          )),
                    ],
                  ),
              ] else ...[
                Text('Tagihan: $_selectedBill', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _paymentNumberController,
                  decoration: const InputDecoration(labelText: 'Nomor Pembayaran', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [RupiahInputFormatter()],
                  decoration: const InputDecoration(labelText: 'Masukkan jumlah', prefixText: 'Rp ', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _saveFavorite,
                      onChanged: (val) {
                        if (!mounted) return;
                        setState(() => _saveFavorite = val ?? false);
                      },
                    ),
                    const Text('Simpan sebagai favorit'),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _payBill,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Bayar', style: TextStyle(fontSize: 16, color: Colors.white),)
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    if (!mounted) return;
                    setState(() {
                      _selectedBill = null;
                      _amountController.clear();
                      _paymentNumberController.clear();
                      _saveFavorite = false;
                    });
                  },
                  child: const Text('Kembali', style: TextStyle(fontSize: 16)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
