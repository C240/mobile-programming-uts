import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/models/account_model.dart';
import 'package:mobile_programming_uts/utils/format.dart';

class ConfirmTransferSheet extends StatelessWidget {
  final Account fromAccount;
  final String toAccountNumber;
  final String? recipientName;
  final double amount;
  final String? description;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const ConfirmTransferSheet({
    super.key,
    required this.fromAccount,
    required this.toAccountNumber,
    required this.amount,
    required this.onCancel,
    required this.onConfirm,
    this.recipientName,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Konfirmasi Transfer', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Dari'),
            subtitle: Text('${fromAccount.accountNumber} • ${formatRupiah(fromAccount.balance)}'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Ke'),
            subtitle: Text(recipientName != null ? '$recipientName • $toAccountNumber' : toAccountNumber),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Jumlah'),
            subtitle: Text(formatRupiah(amount)),
          ),
          if ((description ?? '').isNotEmpty)
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text('Deskripsi'),
              subtitle: Text(description!),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  child: const Text('Konfirmasi'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}