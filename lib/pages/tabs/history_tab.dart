    import 'package:flutter/material.dart';
    import 'package:mobile_programming_uts/data/database_helper.dart';
    import 'package:mobile_programming_uts/models/account_model.dart';
    import 'package:mobile_programming_uts/models/transaction_model.dart';

    class HistoryTab extends StatefulWidget {
      final Account account;
      const HistoryTab({super.key, required this.account});

      @override
      State<HistoryTab> createState() => _HistoryTabState();
    }

    class _HistoryTabState extends State<HistoryTab> {
      Future<List<Transaction>>? _transactionsFuture;

      @override
      void initState() {
        super.initState();
        _loadTransactions();
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
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                bool isDebit = transaction.fromAccountNumber == widget.account.accountNumber;

                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/transaction_detail',
                      arguments: transaction,
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isDebit ? Colors.red : Colors.green,
                      ),
                      title: Text(
                        'Rp ${transaction.amount.toStringAsFixed(0)}',
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
              },
            );
          },
        );
      }
    }
    
