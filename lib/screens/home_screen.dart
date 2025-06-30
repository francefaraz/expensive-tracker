import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/db_helper.dart';
import 'add_transaction_screen.dart';
import '../widgets/expense_bar_chart.dart';
import '../utils/export_helper.dart';
import '../utils/currency_helper.dart';
import '../widgets/currency_dialog.dart';
import 'package:provider/provider.dart';
import '../utils/currency_provider.dart';
import '../utils/format_helper.dart';
import '../widgets/summary_card.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<TransactionModel>>? _transactionsFuture;
  String? _selectedCategory;
  String? _selectedPaymentMethod;
  final List<String> _categories = ['All', 'Food', 'Salary', 'Rent', 'Shopping', 'Others'];
  final List<String> _paymentMethods = ['All', 'Cash', 'Online', 'UPI', 'Bank Transfer'];
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    final txns = await DBHelper.getTransactions();
    setState(() {
      _allTransactions = txns;
      _filteredTransactions = _applyFilters(txns);
      _transactionsFuture = Future.value(_filteredTransactions);
    });
  }

  List<TransactionModel> _applyFilters(List<TransactionModel> txns) {
    return txns.where((txn) {
      final catOk = _selectedCategory == null || _selectedCategory == 'All' || txn.category == _selectedCategory;
      final payOk = _selectedPaymentMethod == null || _selectedPaymentMethod == 'All' || txn.paymentMethod == _selectedPaymentMethod;
      return catOk && payOk;
    }).toList();
  }

  void _onFilterChanged() {
    setState(() {
      _filteredTransactions = _applyFilters(_allTransactions);
      _transactionsFuture = Future.value(_filteredTransactions);
    });
  }

  Map<String, double> _calculateSummary(List<TransactionModel> transactions) {
    double income = 0;
    double expense = 0;
    for (var txn in transactions) {
      if (txn.type == 'income') {
        income += txn.amount;
      } else {
        expense += txn.amount;
      }
    }
    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<CurrencyProvider>(context).currency;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track My Money', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 4,
        shadowColor: AppColors.balance.withOpacity(0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
            onPressed: () async {
              final selected = await showDialog<String>(
                context: context,
                builder: (context) => CurrencyDialog(),
              );
              if (selected != null) {
                Provider.of<CurrencyProvider>(context, listen: false).setCurrency(selected);
                setState(() {}); // Refresh UI
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.textPrimary),
            tooltip: 'Export to CSV',
            onPressed: () async {
              final txns = _allTransactions;
              if (txns.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No transactions to export!')),
                );
                return;
              }
              final path = await ExportHelper.exportTransactionsToCSV(txns);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exported to $path')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (_transactionsFuture == null || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions yet.'));
          }
          final transactions = snapshot.data!;
          final summary = _calculateSummary(transactions);

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SummaryCard(
                      color: AppColors.income,
                      icon: Icons.arrow_upward,
                      title: 'Total Income',
                      value: formatCurrency(summary['income']!, currency),
                    ),
                    SummaryCard(
                      color: AppColors.expense,
                      icon: Icons.arrow_downward,
                      title: 'Total Expense',
                      value: formatCurrency(summary['expense']!, currency),
                    ),
                    SummaryCard(
                      color: AppColors.balance,
                      icon: Icons.account_balance_wallet,
                      title: 'Remaining Balance',
                      value: formatCurrency(summary['balance']!, currency),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  color: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  shadowColor: AppColors.balance.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        ExpenseBarChart(
                          transactions: transactions,
                          categories: _categories.where((c) => c != 'All').toList(),
                        ),
                      ],
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
                            _onFilterChanged();
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
                            _onFilterChanged();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...transactions.map((txn) {
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
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(txn.title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    subtitle: Text('${txn.category} • ${txn.paymentMethod}\n${txn.date.split('T')[0]}', style: const TextStyle(color: AppColors.textSecondary)),
                    trailing: PopupMenuButton<String>(
                      color: AppColors.background,
                      icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
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
                    isThreeLine: true,
                  ),
                );
              }).toList(),
              const SizedBox(height: 80), // For FAB spacing
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
