import 'package:intl/intl.dart';

String formatCurrency(double amount, String currency) {
  final format = NumberFormat.currency(
    locale: currency == 'USD' ? 'en_US' : 'en_IN',
    symbol: currency == 'USD' ? '\$' : '₹',
  );
  return format.format(amount);
}
