class Transaction {
  final int id;
  final String fromAccountNumber;
  final String toAccountNumber;
  final double amount;
  final String? description;
  final String? category;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.fromAccountNumber,
    required this.toAccountNumber,
    required this.amount,
    this.description,
    this.category,
    required this.timestamp,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      fromAccountNumber: map['fromAccountNumber'],
      toAccountNumber: map['toAccountNumber'],
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : double.tryParse('${map['amount']}') ?? 0.0,
      description: map['description'],
      category: map['category'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}