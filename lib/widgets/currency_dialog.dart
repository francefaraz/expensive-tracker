import 'package:flutter/material.dart';
import '../utils/currency_helper.dart';
import 'package:provider/provider.dart';
import '../utils/currency_provider.dart';

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
    return AlertDialog(
      title: const Text('Select Currency'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            value: 'INR',
            groupValue: _selected,
            onChanged: (val) => setState(() => _selected = val),
            title: const Text('INR (₹)'),
          ),
          RadioListTile<String>(
            value: 'USD',
            groupValue: _selected,
            onChanged: (val) => setState(() => _selected = val),
            title: const Text('USD (\$)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_selected != null) {
              Provider.of<CurrencyProvider>(context, listen: false).setCurrency(_selected!);
            }
            Navigator.pop(context, _selected);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
