class Account {
  final int id;
  final int userId;
  final String accountNumber;
  final double balance;

  Account({
    required this.id,
    required this.userId,
    required this.accountNumber,
    required this.balance,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      userId: map['user_id'],
      accountNumber: map['accountNumber'],
      balance: (map['balance'] is num)
          ? (map['balance'] as num).toDouble()
          : double.tryParse(map['balance'].toString()) ?? 0.0,
    );
  }
}