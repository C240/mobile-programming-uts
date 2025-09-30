// lib/widgets/balance_card.dart

import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/models/account_model.dart';

class BalanceCard extends StatelessWidget {
  final Account? account;

  const BalanceCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: account == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo Anda:',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  Text(
                    'Rp ${account!.balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No. Rekening: ${account!.accountNumber}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }
}