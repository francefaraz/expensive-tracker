import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/db_helper.dart';
import 'add_transaction_screen.dart';
import '../utils/currency_helper.dart';
import '../utils/format_helper.dart';
import 'package:provider/provider.dart';
import '../utils/currency_provider.dart';
import '../utils/app_colors.dart';
import '../utils/quick_template_helper.dart';
import '../models/quick_template.dart';
import '../widgets/banner_ad_widget.dart';

final Map<String, IconData> categoryIcons = {
  'Food': Icons.restaurant,
  'Salary': Icons.work,
  'Rent': Icons.home,
  'Shopping': Icons.shopping_bag,
  'Others': Icons.category,
};

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  Future<List<TransactionModel>>? _transactionsFuture;
  String? _selectedCategory;
  String? _selectedPaymentMethod;
  final List<String> _categories = ['All', 'Food', 'Salary', 'Rent', 'Shopping', 'Others'];
  final List<String> _paymentMethods = ['All', 'Cash', 'Online', 'UPI', 'Bank Transfer'];
  List<TransactionModel> _allTransactions = [];
  List<QuickTemplate> _quickTemplates = [];

  // Date filter variables
  final List<String> _dateFilters = [
    'Last 30 days',
    'Last 90 days',
    'Last 1 year',
    'All',
    'Custom Range',
  ];
  String _selectedDateFilter = 'Last 30 days';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadQuickTemplates();
  }

  void _loadTransactions() async {
    try {
      final txns = await DBHelper.getTransactions();
      if (mounted) {
        setState(() {
          _allTransactions = txns;
          _transactionsFuture = Future.value(_applyFilters());
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading transactions: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadQuickTemplates() async {
    final templates = await QuickTemplateHelper.loadTemplates();
    setState(() {
      _quickTemplates = templates;
    });
  }

  Future<void> _addTransactionFromTemplate(QuickTemplate template) async {
    final txn = TransactionModel(
      type: template.type,
      title: template.title,
      amount: template.amount,
      paymentMethod: template.paymentMethod,
      category: template.category,
      date: DateTime.now().toIso8601String(),
      note: null,
      tag: template.provider,
    );
    await DBHelper.insertTransaction(txn);
    _loadTransactions();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added: ${template.title} ${formatCurrency(template.amount, Provider.of<CurrencyProvider>(context, listen: false).currency)}')),
      );
    }
  }

  List<TransactionModel> _applyFilters() {
    DateTime now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate = now;
    switch (_selectedDateFilter) {
      case 'Last 30 days':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'Last 90 days':
        startDate = now.subtract(const Duration(days: 90));
        break;
      case 'Last 1 year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case 'Custom Range':
        startDate = _customStartDate;
        endDate = _customEndDate ?? now;
        break;
      case 'All':
      default:
        startDate = null;
        break;
    }
    return _allTransactions.where((txn) {
      final catOk = _selectedCategory == null || _selectedCategory == 'All' || txn.category == _selectedCategory;
      final payOk = _selectedPaymentMethod == null || _selectedPaymentMethod == 'All' || txn.paymentMethod == _selectedPaymentMethod;
      final date = DateTime.parse(txn.date);
      final dateOk = startDate == null
          || (date.isAfter(startDate.subtract(const Duration(days: 1)))
              && (endDate == null || date.isBefore(endDate.add(const Duration(days: 1)))));
      return catOk && payOk && dateOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<CurrencyProvider>(context).currency;
    final currencyFormat = NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 4,
        shadowColor: AppColors.balance.withOpacity(0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (_transactionsFuture == null || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions yet.', style: TextStyle(color: AppColors.textPrimary)));
          }
          final transactions = snapshot.data!;

          return Column(
            children: [
              if (_quickTemplates.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: SizedBox(
                    height: 44,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_quickTemplates.length, (i) {
                          final t = _quickTemplates[i];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Material(
                              color: Colors.transparent,
                              elevation: 4,
                              borderRadius: BorderRadius.circular(16),
                              child: ActionChip(
                                backgroundColor: t.type == 'income' ? AppColors.income : AppColors.balance,
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      t.type == 'income' ? Icons.add : Icons.remove,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${t.title} ${formatCurrency(t.amount, currency)} ${t.paymentMethod}${t.provider != null ? ' (${t.provider})' : ''}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                onPressed: () => _addTransactionFromTemplate(t),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                shadowColor: AppColors.balance.withOpacity(0.25),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedCategory ?? 'All',
                        isExpanded: true,
                        dropdownColor: AppColors.background,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                            _transactionsFuture = Future.value(_applyFilters());
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedPaymentMethod ?? 'All',
                        isExpanded: true,
                        dropdownColor: AppColors.background,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: _paymentMethods.map((pm) => DropdownMenuItem(value: pm, child: Text(pm, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value;
                            _transactionsFuture = Future.value(_applyFilters());
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Date filter dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedDateFilter,
                        isExpanded: true,
                        dropdownColor: AppColors.background,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: _dateFilters.map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
                        onChanged: (value) async {
                          if (value == 'Custom Range') {
                            // Pick custom start and end dates
                            final pickedStart = await showDatePicker(
                              context: context,
                              initialDate: _customStartDate ?? DateTime.now().subtract(const Duration(days: 30)),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (pickedStart != null) {
                              final pickedEnd = await showDatePicker(
                                context: context,
                                initialDate: _customEndDate ?? DateTime.now(),
                                firstDate: pickedStart,
                                lastDate: DateTime.now(),
                              );
                              setState(() {
                                _selectedDateFilter = value!;
                                _customStartDate = pickedStart;
                                _customEndDate = pickedEnd ?? pickedStart;
                                _transactionsFuture = Future.value(_applyFilters());
                              });
                            }
                          } else {
                            setState(() {
                              _selectedDateFilter = value!;
                              _transactionsFuture = Future.value(_applyFilters());
                            });
                          }
                        },
                      ),
                    ),
                    if (_selectedDateFilter == 'Custom Range' && _customStartDate != null && _customEndDate != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '${DateFormat.yMMMd().format(_customStartDate!)} - ${DateFormat.yMMMd().format(_customEndDate!)}',
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final txn = transactions[index];
                    final isIncome = txn.type == 'income';
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: AppColors.background,
                      elevation: 3,
                      shadowColor: isIncome ? AppColors.income.withOpacity(0.08) : AppColors.expense.withOpacity(0.08),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: isIncome ? AppColors.income : AppColors.expense,
                          child: Icon(
                            categoryIcons[txn.category] ?? Icons.category,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          txn.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                        ),
                        subtitle: Text(
                          '${txn.category} • ${txn.paymentMethod}\n${DateFormat.yMMMd().format(DateTime.parse(txn.date))}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              (isIncome ? '+ ' : '- ') + formatCurrency(txn.amount, currency),
                              style: TextStyle(
                                color: isIncome ? AppColors.income : AppColors.expense,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              color: AppColors.background,
                              icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textPrimary),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddTransactionScreen(
                                        transaction: txn,
                                        onTransactionSaved: _loadTransactions, // Pass callback
                                      ),
                                    ),
                                  );
                                  if (result == true) _loadTransactions();
                                } else if (value == 'delete') {
                                  await DBHelper.deleteTransaction(txn.id!);
                                  _loadTransactions();
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: AppColors.textPrimary))),
                                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.textPrimary))),
                              ],
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.balance,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Transaction', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTransactionScreen(
              onTransactionSaved: _loadTransactions, // Pass callback to refresh data
            )),
          );
          if (result == true) {
            _loadTransactions(); // Also keep this as backup
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}
