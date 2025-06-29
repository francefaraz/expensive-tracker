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
        title: const Text('Track My Money', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
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
            icon: const Icon(Icons.download),
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
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryItem(
                          label: 'Total',
                          value: summary['income']!,
                          color: Colors.teal,
                          icon: Icons.arrow_upward,
                        ),
                        _SummaryItem(
                          label: 'Expense',
                          value: summary['expense']!,
                          color: Colors.red,
                          icon: Icons.arrow_downward,
                        ),
                        _SummaryItem(
                          label: 'Balance',
                          value: summary['balance']!,
                          color: Colors.blue,
                          icon: Icons.account_balance_wallet,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
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
                        items: _paymentMethods.map((pm) => DropdownMenuItem(value: pm, child: Text(pm))).toList(),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isIncome ? Colors.green : Colors.red,
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(txn.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${txn.category} • ${txn.paymentMethod}\n${txn.date.split('T')[0]}'),
                    trailing: PopupMenuButton<String>(
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
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
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
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
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

class _SummaryItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<CurrencyProvider>(context).currency;
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          formatCurrency(value, currency),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
