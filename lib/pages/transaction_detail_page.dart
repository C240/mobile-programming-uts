// lib/pages/transaction_detail_page.dart

import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/models/transaction_model.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transaction = ModalRoute.of(context)!.settings.arguments as Transaction;

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
            _buildDetailRow('Jumlah', 'Rp ${transaction.amount.toStringAsFixed(0)}'),
            _buildDetailRow('Dari', transaction.fromAccountNumber),
            _buildDetailRow('Ke', transaction.toAccountNumber),
            _buildDetailRow('Deskripsi', transaction.description ?? '-'),
            _buildDetailRow('Waktu', '${transaction.timestamp.day}/${transaction.timestamp.month}/${transaction.timestamp.year} ${transaction.timestamp.hour}:${transaction.timestamp.minute}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/dashboard');
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
}