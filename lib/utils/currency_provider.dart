import 'package:flutter/material.dart';
import 'currency_helper.dart';

class CurrencyProvider extends ChangeNotifier {
  String _currency = 'INR';

  String get currency => _currency;

  CurrencyProvider() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    _currency = await CurrencyHelper.getCurrency();
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    await CurrencyHelper.setCurrency(currency);
    _currency = currency;
    notifyListeners();
  }
} 