// lib/pages/history_page.dart

import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/models/account_model.dart';
import 'package:mobile_programming_uts/models/transaction_model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTransactions();
  }

  void _loadTransactions() async {
    final account = ModalRoute.of(context)!.settings.arguments as Account;
    var transactionMaps = await DatabaseHelper().getTransactions(account.accountNumber);
    setState(() {
      _transactions = transactionMaps.map((map) => Transaction.fromMap(map)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final account = ModalRoute.of(context)!.settings.arguments as Account;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(child: Text('Belum ada transaksi.'))
              : ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    bool isDebit = transaction.fromAccountNumber == account.accountNumber;

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
                      )
                    );
                  },
                ),
    );
  }
}