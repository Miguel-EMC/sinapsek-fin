import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String usd(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: r'$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String simple(double amount) {
    final formatter = NumberFormat.simpleCurrency(
      locale: 'en_US',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}
