// lib/models/transaction_model.dart

class Transaction {
  final int id;
  final String fromAccountNumber;
  final String toAccountNumber;
  final double amount;
  final String? description;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.fromAccountNumber,
    required this.toAccountNumber,
    required this.amount,
    this.description,
    required this.timestamp,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      fromAccountNumber: map['fromAccountNumber'],
      toAccountNumber: map['toAccountNumber'],
      amount: map['amount'],
      description: map['description'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}