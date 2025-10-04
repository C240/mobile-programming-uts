import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/models/account_model.dart';
import 'package:mobile_programming_uts/models/transaction_model.dart';
import 'package:mobile_programming_uts/utils/category_utils.dart';
import 'package:mobile_programming_uts/widgets/transaction_list_item.dart';
import 'package:mobile_programming_uts/widgets/category_chip.dart';

class HistoryTab extends StatefulWidget {
      final Account account;
      final String? initialCategory;
      const HistoryTab({super.key, required this.account, this.initialCategory});

      @override
      State<HistoryTab> createState() => _HistoryTabState();
    }

class _HistoryTabState extends State<HistoryTab> {
  Future<List<Transaction>>? _transactionsFuture;
  String? _selectedCategory;

      @override
      void initState() {
        super.initState();
        _loadTransactions();
        _selectedCategory = widget.initialCategory;
      }

  void _loadTransactions() {
    setState(() {
      _transactionsFuture = DatabaseHelper()
          .getTransactions(widget.account.accountNumber)
          .then((maps) => maps.map((map) => Transaction.fromMap(map)).toList());
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Transaction>>(
      future: _transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada transaksi.'));
        }

        final transactions = snapshot.data!;
        
        final categories = <String>{};
        for (final t in transactions) {
          categories.add(t.category ?? categorize(t.description));
        }
        final filtered = _selectedCategory == null
            ? transactions
            : transactions.where((t) => (t.category ?? categorize(t.description)) == _selectedCategory).toList();

        return ListView(
          children: [
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Semua'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                  const SizedBox(width: 8),
                  for (final c in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CategoryChip(
                        label: c,
                        selected: _selectedCategory == c,
                        onSelected: (_) => setState(() => _selectedCategory = c),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (final transaction in filtered)
              Builder(builder: (context) {
                final isDebit = transaction.fromAccountNumber == widget.account.accountNumber;
                return TransactionListItem(
                  transaction: transaction,
                  isDebit: isDebit,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/transaction_detail',
                      arguments: transaction,
                    );
                  },
                );
              }),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
    
