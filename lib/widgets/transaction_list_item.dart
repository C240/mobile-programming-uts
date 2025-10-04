import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/models/transaction_model.dart';
import 'package:mobile_programming_uts/utils/format.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final bool isDebit;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.isDebit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ListTile(
          leading: Icon(
            isDebit ? Icons.arrow_upward : Icons.arrow_downward,
            color: isDebit ? Colors.red : Colors.green,
          ),
          title: Text(
            formatRupiah(transaction.amount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            isDebit
                ? 'Transfer ke ${transaction.toAccountNumber}'
                : 'Terima dari ${transaction.fromAccountNumber}',
          ),
          trailing: Text(
            '${transaction.timestamp.day}/${transaction.timestamp.month}/${transaction.timestamp.year}',
          ),
        ),
      ),
    );
  }
}