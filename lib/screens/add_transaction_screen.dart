import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/db_helper.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const AddTransactionScreen({Key? key, this.transaction}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'expense';
  String _title = '';
  double _amount = 0.0;
  String _paymentMethod = 'Cash';
  String _category = 'Food';
  DateTime _date = DateTime.now();
  String? _note;
  String? _tag;

  final List<String> _paymentMethods = ['Cash', 'Online', 'UPI', 'Bank Transfer'];
  final List<String> _categories = ['Food', 'Salary', 'Rent', 'Shopping', 'Others'];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _type = t.type;
      _title = t.title;
      _amount = t.amount;
      _paymentMethod = t.paymentMethod;
      _category = t.category;
      _date = DateTime.parse(t.date);
      _note = t.note;
      _tag = t.tag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ToggleButtons(
                isSelected: [_type == 'expense', _type == 'income'],
                onPressed: (index) {
                  setState(() {
                    _type = index == 0 ? 'expense' : 'income';
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Expense'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Income'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title/Name'),
                validator: (value) => value == null || value.isEmpty ? 'Enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Enter amount' : null,
                onSaved: (value) => _amount = double.tryParse(value!) ?? 0.0,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _paymentMethod,
                items: _paymentMethods.map((pm) => DropdownMenuItem(value: pm, child: Text(pm))).toList(),
                onChanged: (value) => setState(() => _paymentMethod = value as String),
                decoration: const InputDecoration(labelText: 'Payment Method'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _category,
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (value) => setState(() => _category = value as String),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Date: ${_date.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                onSaved: (value) => _note = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tag (Source/Destination, optional)'),
                onSaved: (value) => _tag = value,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final txn = TransactionModel(
                      id: widget.transaction?.id,
                      type: _type,
                      title: _title,
                      amount: _amount,
                      paymentMethod: _paymentMethod,
                      category: _category,
                      date: _date.toIso8601String(),
                      note: _note,
                      tag: _tag,
                    );
                    if (widget.transaction == null) {
                      await DBHelper.insertTransaction(txn);
                    } else {
                      await DBHelper.updateTransaction(txn);
                    }
                    Navigator.pop(context, true);
                  }
                },
                child: Text(widget.transaction == null ? 'Save' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
