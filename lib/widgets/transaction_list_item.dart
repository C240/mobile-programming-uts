import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/models/transaction_model.dart';
import 'package:mobile_programming_uts/utils/format.dart';
import 'package:mobile_programming_uts/utils/category_utils.dart';
import 'package:mobile_programming_uts/utils/ui.dart';
import 'package:mobile_programming_uts/widgets/category_avatar.dart';

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
          leading: CategoryAvatar(category: (transaction.category ?? categorize(transaction.description))),
          title: Text(
            formatRupiah(transaction.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: amountColor(isDebit),
            ),
          ),
          subtitle: Text(
            '${isDebit ? 'Transfer ke' : 'Terima dari'} ${isDebit ? transaction.toAccountNumber : transaction.fromAccountNumber}\nKategori: ${(transaction.category ?? categorize(transaction.description))}',
          ),
          trailing: Text(formatDateShort(transaction.timestamp)),
        ),
      ),
    );
  }
}