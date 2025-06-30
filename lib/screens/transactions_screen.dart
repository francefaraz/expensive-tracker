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

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    final txns = await DBHelper.getTransactions();
    setState(() {
      _allTransactions = txns;
      _transactionsFuture = Future.value(_applyFilters());
    });
  }

  List<TransactionModel> _applyFilters() {
    return _allTransactions.where((txn) {
      final catOk = _selectedCategory == null || _selectedCategory == 'All' || txn.category == _selectedCategory;
      final payOk = _selectedPaymentMethod == null || _selectedPaymentMethod == 'All' || txn.paymentMethod == _selectedPaymentMethod;
      return catOk && payOk;
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
                                      builder: (_) => AddTransactionScreen(transaction: txn),
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
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
          if (result == true) {
            _loadTransactions();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
