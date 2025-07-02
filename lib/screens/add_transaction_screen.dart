import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/db_helper.dart';
import '../utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/quick_template_helper.dart';
import '../models/quick_template.dart';

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
  String? _provider;
  bool _showAddProviderField = false;
  final TextEditingController _newProviderController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  final List<String> _paymentMethods = ['Cash', 'Online', 'UPI', 'Bank Transfer'];
  final List<String> _categories = ['Food', 'Salary', 'Rent', 'Shopping', 'Others'];

  final Map<String, List<String>> _defaultProviders = {
    'UPI': ['GPay', 'PhonePe', 'Paytm', 'CRED', 'Slice', 'Other'],
    'Card': ['Axis', 'HDFC', 'SBI', 'ICICI', 'Other'],
    'Wallet': ['Amazon Pay', 'Mobikwik', 'Paytm Wallet', 'Other'],
    'Bank Transfer': ['SBI', 'HDFC', 'ICICI', 'Axis', 'Other'],
  };
  Map<String, List<String>> _customProviders = {
    'UPI': [],
    'Card': [],
    'Wallet': [],
    'Bank Transfer': [],
  };

  List<QuickTemplate> _quickTemplates = [];

  @override
  void initState() {
    super.initState();
    _loadCustomProviders();
    _loadQuickTemplates();
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
      _provider = t.tag;
      _titleController.text = t.title;
      _amountController.text = t.amount.toString();
      _noteController.text = t.note ?? '';
      _tagController.text = t.tag ?? '';
      if ((_paymentMethod == 'UPI' || _paymentMethod == 'Card' || _paymentMethod == 'Wallet' || _paymentMethod == 'Bank Transfer') && t.tag != null) {
        if (!_defaultProviders[_paymentMethod]!.contains(t.tag) && !_customProviders[_paymentMethod]!.contains(t.tag)) {
          _customProviders[_paymentMethod]!.add(t.tag!);
        }
      }
    }
  }

  Future<void> _loadCustomProviders() async {
    final prefs = await SharedPreferences.getInstance();
    for (var key in _customProviders.keys) {
      _customProviders[key] = prefs.getStringList('custom_providers_$key') ?? [];
    }
    setState(() {});
  }

  Future<void> _addCustomProvider(String method, String provider) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_customProviders[method]!.contains(provider)) {
      _customProviders[method]!.add(provider);
      await prefs.setStringList('custom_providers_$method', _customProviders[method]!);
      setState(() {});
    }
  }

  Future<void> _loadQuickTemplates() async {
    final templates = await QuickTemplateHelper.loadTemplates();
    setState(() {
      _quickTemplates = templates;
    });
  }

  void _fillFormFromTemplate(QuickTemplate t) {
    setState(() {
      _type = t.type;
      _title = t.title;
      _amount = t.amount;
      _paymentMethod = t.paymentMethod;
      _category = t.category;
      _provider = t.provider;
      _titleController.text = t.title;
      _amountController.text = t.amount.toString();
      if (t.provider != null) {
        if ((_paymentMethod == 'UPI' || _paymentMethod == 'Card' || _paymentMethod == 'Wallet' || _paymentMethod == 'Bank Transfer') &&
            !_defaultProviders[_paymentMethod]!.contains(t.provider) &&
            !_customProviders[_paymentMethod]!.contains(t.provider)) {
          _customProviders[_paymentMethod]!.add(t.provider!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 4,
        shadowColor: AppColors.balance.withOpacity(0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_quickTemplates.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    color: AppColors.background,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: SizedBox(
                        height: 44,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _quickTemplates.map((t) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ActionChip(
                                backgroundColor: t.type == 'income'
                                    ? AppColors.income.withOpacity(0.85)
                                    : AppColors.expense.withOpacity(0.85),
                                avatar: Icon(
                                  t.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                label: Text(
                                  '${t.title} ₹${t.amount} ${t.paymentMethod}${t.provider != null ? ' (${t.provider})' : ''}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () => _fillFormFromTemplate(t),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                shadowColor: AppColors.balance.withOpacity(0.18),
                              ),
                            )).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // --- Income/Expense Selection ---
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: _type == 'expense' ? AppColors.expense : AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _type == 'expense'
                              ? [BoxShadow(color: AppColors.expense.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 2))]
                              : [],
                          border: Border.all(
                            color: _type == 'expense' ? AppColors.expense : AppColors.balance,
                            width: 2,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            setState(() {
                              _type = 'expense';
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_upward, color: _type == 'expense' ? Colors.white : AppColors.expense, size: 28),
                                const SizedBox(height: 6),
                                Text(
                                  'Expense',
                                  style: TextStyle(
                                    color: _type == 'expense' ? Colors.white : AppColors.expense,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: _type == 'income' ? AppColors.income : AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _type == 'income'
                              ? [BoxShadow(color: AppColors.income.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 2))]
                              : [],
                          border: Border.all(
                            color: _type == 'income' ? AppColors.income : AppColors.balance,
                            width: 2,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            setState(() {
                              _type = 'income';
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_downward, color: _type == 'income' ? Colors.white : AppColors.income, size: 28),
                                const SizedBox(height: 6),
                                Text(
                                  'Income',
                                  style: TextStyle(
                                    color: _type == 'income' ? Colors.white : AppColors.income,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Title/Name',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.balance, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.income, width: 2),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.balance, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.income, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Enter amount' : null,
                onSaved: (value) => _amount = double.tryParse(value!) ?? 0.0,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _paymentMethod,
                dropdownColor: AppColors.background,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.balance, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.income, width: 2),
                  ),
                ),
                items: ['Cash', 'UPI', 'Card', 'Bank Transfer', 'Wallet']
                    .map((pm) => DropdownMenuItem(value: pm, child: Text(pm, style: const TextStyle(color: AppColors.textPrimary))))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value as String;
                    _provider = null;
                    _showAddProviderField = false;
                  });
                },
              ),
              if (_paymentMethod == 'UPI' || _paymentMethod == 'Card' || _paymentMethod == 'Wallet' || _paymentMethod == 'Bank Transfer')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _provider,
                      dropdownColor: AppColors.background,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Provider',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.balance, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.income, width: 2),
                        ),
                      ),
                      items: [
                        ...?_defaultProviders[_paymentMethod],
                        ...?_customProviders[_paymentMethod],
                      ].map((prov) => DropdownMenuItem(value: prov, child: Text(prov, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
                      onChanged: (value) {
                        setState(() {
                          _provider = value;
                          _showAddProviderField = value == 'Other';
                        });
                      },
                    ),
                    if (_showAddProviderField)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _newProviderController,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  labelText: 'Add New Provider',
                                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppColors.balance, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppColors.income, width: 2),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check, color: AppColors.income),
                              onPressed: () async {
                                final newProvider = _newProviderController.text.trim();
                                if (newProvider.isNotEmpty) {
                                  await _addCustomProvider(_paymentMethod, newProvider);
                                  setState(() {
                                    _provider = newProvider;
                                    _showAddProviderField = false;
                                    _newProviderController.clear();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _category,
                dropdownColor: AppColors.background,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.balance, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.income, width: 2),
                  ),
                ),
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
                onChanged: (value) => setState(() => _category = value as String),
              ),
              const SizedBox(height: 16),
              ListTile(
                tileColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text('Date: ${_date.toLocal().toString().split(' ')[0]}', style: const TextStyle(color: AppColors.textPrimary)),
                trailing: const Icon(Icons.calendar_today, color: AppColors.balance),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: AppColors.balance,
                            onPrimary: AppColors.textPrimary,
                            surface: AppColors.background,
                            onSurface: AppColors.textPrimary,
                          ),
                          dialogBackgroundColor: AppColors.background,
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.balance, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.income, width: 2),
                  ),
                ),
                onSaved: (value) => _note = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Tag (Source/Destination, optional)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.balance, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.income, width: 2),
                  ),
                ),
                onSaved: (value) => _tag = value,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.balance,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
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
                              tag: _provider ?? _tag,
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
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.income,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          final template = QuickTemplate(
                            type: _type,
                            title: _title,
                            amount: _amount,
                            paymentMethod: _paymentMethod,
                            category: _category,
                            provider: _provider,
                          );
                          await QuickTemplateHelper.addTemplate(template);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Template saved!')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save as Template'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
