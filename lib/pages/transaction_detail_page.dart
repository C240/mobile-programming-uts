import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/utils/format.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/models/transaction_model.dart';
import 'package:mobile_programming_uts/utils/category_utils.dart';

class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({super.key});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late final Transaction transaction;
  String? senderName;
  String? recipientName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    transaction = ModalRoute.of(context)!.settings.arguments as Transaction;
    _loadNames();
  }

  Future<void> _loadNames() async {
    final sender = await DatabaseHelper().getUserByAccountNumber(transaction.fromAccountNumber);
    final receiver = await DatabaseHelper().getUserByAccountNumber(transaction.toAccountNumber);
    if (!mounted) return;
    setState(() {
      senderName = sender?.username;
      recipientName = receiver?.username;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatted = formatDateTimeLong(transaction.timestamp);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Transfer Berhasil',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Jumlah', formatRupiah(transaction.amount)),
            _buildDetailRow('Dari', transaction.fromAccountNumber),
            _buildDetailRow('Nama Pengirim', senderName ?? '-'),
            _buildDetailRow('Ke', transaction.toAccountNumber),
            _buildDetailRow('Nama Penerima', recipientName ?? '-'),
            _buildDetailRow('Deskripsi', transaction.description ?? '-'),
            _buildCategoryRow(transaction.category),
            _buildDetailRow('Waktu', formatted),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/main');
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Selesai'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String? category) {
    final c = category;
    if (c == null || c.isEmpty) {
      return const SizedBox.shrink();
    }
    final icon = iconForCategory(c);
    final color = colorForCategory(c);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Kategori', style: TextStyle(color: Colors.grey)),
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 6),
              Text(c, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  
}