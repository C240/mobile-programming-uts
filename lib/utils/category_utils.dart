import 'package:flutter/material.dart';

String categorize(String? desc) {
  final d = (desc ?? '').toLowerCase();
  if (d.contains('topup') || d.contains('top-up') || d.contains('pulsa') || d.contains('data')) {
    return 'Top-Up & Data';
  }
  if (d.contains('bill') || d.contains('tagihan') || d.contains('pln') || d.contains('pdam')) {
    return 'Bills';
  }
  if (d.contains('ewallet') || d.contains('ovo') || d.contains('dana') || d.contains('gopay')) {
    return 'E-Wallet';
  }
  return 'Transfer';
}

const IconData kDefaultCategoryIcon = Icons.label_outline;
const Color kDefaultCategoryColor = Colors.grey;

const Map<String, IconData> kCategoryIcons = {
  'Belanja': Icons.shopping_cart,
  'Kesehatan': Icons.local_hospital,
  'Hiburan': Icons.movie,
  'Transportasi': Icons.directions_car,
  'Makan': Icons.restaurant,
  'Tagihan': Icons.receipt_long,
  'Bills': Icons.receipt_long,
  'Pendidikan': Icons.school,
  'E-Wallet': Icons.account_balance_wallet,
  'Top-Up & Data': Icons.signal_cellular_alt,
  'Transfer': Icons.swap_horiz,
};

IconData iconForCategory(String c) {
  return kCategoryIcons[c] ?? kDefaultCategoryIcon;
}

const Map<String, Color> kCategoryColors = {
  'Belanja': Colors.deepOrange,
  'Kesehatan': Colors.redAccent,
  'Hiburan': Colors.purple,
  'Transportasi': Colors.blueGrey,
  'Makan': Colors.orange,
  'Tagihan': Colors.teal,
  'Bills': Colors.teal,
  'Pendidikan': Colors.indigo,
  'E-Wallet': Colors.blueAccent,
  'Top-Up & Data': Colors.green,
  'Transfer': Colors.cyan,
};

Color colorForCategory(String c) {
  return kCategoryColors[c] ?? kDefaultCategoryColor;
}