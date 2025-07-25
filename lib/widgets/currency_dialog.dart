import 'package:flutter/material.dart';
import '../utils/currency_helper.dart';
import 'package:provider/provider.dart';
import '../utils/currency_provider.dart';
import '../utils/app_colors.dart';

class CurrencyDialog extends StatefulWidget {
  @override
  State<CurrencyDialog> createState() => _CurrencyDialogState();
}

class _CurrencyDialogState extends State<CurrencyDialog> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    CurrencyHelper.getCurrency().then((value) {
      setState(() {
        _selected = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const List<Map<String, String>> currencies = [
      {'code': 'INR', 'symbol': '₹'},
      {'code': 'USD', 'symbol': ' 24'},
    ];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.background,
      title: const Text('Select Currency', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: currencies.map((currency) => RadioListTile<String>(
            activeColor: AppColors.balance,
            title: Text('${currency['code']} (${currency['symbol']})', style: const TextStyle(color: AppColors.textPrimary)),
            value: currency['code']!,
            groupValue: _selected,
            onChanged: (value) {
              setState(() {
                _selected = value;
              });
            },
          )).toList(),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.income,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
