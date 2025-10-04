import 'package:intl/intl.dart';

final NumberFormat _idrCurrency = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
);

final NumberFormat _idrDecimal = NumberFormat.decimalPattern('id_ID');

String formatRupiah(num value) {
  return _idrCurrency.format(value);
}

String formatDecimal(num value) {
  return _idrDecimal.format(value);
}

double parseRupiahToDouble(String input) {
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return 0;
  return double.parse(digits);
}