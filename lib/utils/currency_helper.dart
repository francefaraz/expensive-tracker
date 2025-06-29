import 'package:shared_preferences/shared_preferences.dart';

class CurrencyHelper {
  static const String _currencyKey = 'selected_currency';

  static Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
  }

  static Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? 'INR'; // Default to INR
  }
}
