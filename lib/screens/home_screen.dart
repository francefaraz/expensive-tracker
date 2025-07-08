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
import '../utils/quick_template_helper.dart';
import '../models/quick_template.dart';
import 'transactions_screen.dart';
import 'settings_screen.dart';

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
  List<QuickTemplate> _quickTemplates = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadQuickTemplates();
  }

  void _loadTransactions() async {
    final txns = await DBHelper.getTransactions();
    setState(() {
      _allTransactions = txns;
      _filteredTransactions = _applyFilters(txns);
      _transactionsFuture = Future.value(_filteredTransactions);
    });
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

  Future<void> _deleteTemplate(int index) async {
    await QuickTemplateHelper.removeTemplate(index);
    await _loadQuickTemplates();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template deleted.')),
      );
    }
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
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
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
                child: Builder(
                  builder: (context) {
                    final incomeStr = formatCurrency(summary['income']!, currency);
                    final expenseStr = formatCurrency(summary['expense']!, currency);
                    final balanceStr = formatCurrency(summary['balance']!, currency);
                    final threshold = 8;
                    final isIncomeLong = incomeStr.length >= threshold;
                    final isExpenseLong = expenseStr.length >= threshold;
                    final isBalanceLong = balanceStr.length >= threshold;
                    final cardSpacing = 12.0;
                    final fullWidth = MediaQuery.of(context).size.width - 32; // 16 padding each side
                    final halfWidth = (MediaQuery.of(context).size.width - 32 - cardSpacing) / 2;

                    List<Widget> rows = [];

                    // Income row
                    if (isIncomeLong) {
                      rows.add(SummaryCard(
                        color: AppColors.income,
                        icon: Icons.arrow_upward,
                        title: 'Total Income',
                        value: incomeStr,
                        width: fullWidth,
                      ));
                      rows.add(SizedBox(height: cardSpacing));
                      // Now check expense and balance
                      if (isExpenseLong) {
                        rows.add(SummaryCard(
                          color: AppColors.expense,
                          icon: Icons.arrow_downward,
                          title: 'Total Expense',
                          value: expenseStr,
                          width: fullWidth,
                        ));
                        rows.add(SizedBox(height: cardSpacing));
                        // Now check balance
                        if (isBalanceLong) {
                          rows.add(SummaryCard(
                            color: AppColors.balance,
                            icon: Icons.account_balance_wallet,
                            title: 'Remaining Balance',
                            value: balanceStr,
                            width: fullWidth,
                          ));
                        } else {
                          rows.add(SummaryCard(
                            color: AppColors.balance,
                            icon: Icons.account_balance_wallet,
                            title: 'Remaining Balance',
                            value: balanceStr,
                            width: fullWidth,
                          ));
                        }
                      } else {
                        // Expense is short, check balance
                        if (isBalanceLong) {
                          rows.add(Row(
                            children: [
                              Expanded(child: SummaryCard(
                                color: AppColors.expense,
                                icon: Icons.arrow_downward,
                                title: 'Total Expense',
                                value: expenseStr,
                              )),
                              SizedBox(width: cardSpacing),
                              Expanded(child: SummaryCard(
                                color: AppColors.balance,
                                icon: Icons.account_balance_wallet,
                                title: 'Remaining Balance',
                                value: balanceStr,
                              )),
                            ],
                          ));
                        } else {
                          rows.add(Row(
                            children: [
                              Expanded(child: SummaryCard(
                                color: AppColors.expense,
                                icon: Icons.arrow_downward,
                                title: 'Total Expense',
                                value: expenseStr,
                              )),
                              SizedBox(width: cardSpacing),
                              Expanded(child: SummaryCard(
                                color: AppColors.balance,
                                icon: Icons.account_balance_wallet,
                                title: 'Remaining Balance',
                                value: balanceStr,
                              )),
                            ],
                          ));
                        }
                      }
                    } else {
                      // Income is short
                      if (isExpenseLong) {
                        rows.add(Row(
                          children: [
                            Expanded(child: SummaryCard(
                              color: AppColors.income,
                              icon: Icons.arrow_upward,
                              title: 'Total Income',
                              value: incomeStr,
                            )),
                            SizedBox(width: cardSpacing),
                            Expanded(child: SummaryCard(
                              color: AppColors.expense,
                              icon: Icons.arrow_downward,
                              title: 'Total Expense',
                              value: expenseStr,
                              width: fullWidth,
                            )),
                          ],
                        ));
                        rows.add(SizedBox(height: cardSpacing));
                        // Now check balance
                        if (isBalanceLong) {
                          rows.add(SummaryCard(
                            color: AppColors.balance,
                            icon: Icons.account_balance_wallet,
                            title: 'Remaining Balance',
                            value: balanceStr,
                            width: fullWidth,
                          ));
                        } else {
                          rows.add(SummaryCard(
                            color: AppColors.balance,
                            icon: Icons.account_balance_wallet,
                            title: 'Remaining Balance',
                            value: balanceStr,
                            width: fullWidth,
                          ));
                        }
                      } else {
                        // Both income and expense are short
                        if (isBalanceLong) {
                          rows.add(Row(
                            children: [
                              Expanded(child: SummaryCard(
                                color: AppColors.income,
                                icon: Icons.arrow_upward,
                                title: 'Total Income',
                                value: incomeStr,
                              )),
                              SizedBox(width: cardSpacing),
                              Expanded(child: SummaryCard(
                                color: AppColors.expense,
                                icon: Icons.arrow_downward,
                                title: 'Total Expense',
                                value: expenseStr,
                              )),
                            ],
                          ));
                          rows.add(SizedBox(height: cardSpacing));
                          rows.add(SummaryCard(
                            color: AppColors.balance,
                            icon: Icons.account_balance_wallet,
                            title: 'Remaining Balance',
                            value: balanceStr,
                            width: fullWidth,
                          ));
                        } else {
                          // All short, show all three side by side
                          rows.add(Row(
                            children: [
                              Expanded(child: SummaryCard(
                                color: AppColors.income,
                                icon: Icons.arrow_upward,
                                title: 'Total Income',
                                value: incomeStr,
                              )),
                              SizedBox(width: cardSpacing),
                              Expanded(child: SummaryCard(
                                color: AppColors.expense,
                                icon: Icons.arrow_downward,
                                title: 'Total Expense',
                                value: expenseStr,
                              )),
                              SizedBox(width: cardSpacing),
                              Expanded(child: SummaryCard(
                                color: AppColors.balance,
                                icon: Icons.account_balance_wallet,
                                title: 'Remaining Balance',
                                value: balanceStr,
                              )),
                            ],
                          ));
                        }
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: rows,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flash_on, color: AppColors.expense, size: 20),
                        const SizedBox(width: 6),
                        const Text('Quick Add', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color: AppColors.background,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: _quickTemplates.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('No quick templates saved yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                              )
                            : SizedBox(
                                height: 44,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(_quickTemplates.length, (i) {
                                      final t = _quickTemplates[i];
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: GestureDetector(
                                          onLongPress: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                backgroundColor: AppColors.background,
                                                title: const Text('Delete Template', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                                content: Text('Delete template "${t.title}"?', style: const TextStyle(color: AppColors.textSecondary)),
                                                actions: [
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: AppColors.textSecondary,
                                                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: AppColors.expense,
                                                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              _deleteTemplate(i);
                                            }
                                          },
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
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: const [
                    Icon(Icons.history, color: AppColors.textPrimary, size: 20),
                    SizedBox(width: 6),
                    Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  color: AppColors.background,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      if (transactions.take(10).isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text('No recent transactions.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        ),
                      ...transactions.take(10).map((txn) {
                        final isIncome = txn.type == 'income';
                        return Column(
                          children: [
                            ListTile(
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
                            if (txn != transactions.take(10).last)
                              const Divider(height: 1, color: Color(0xFFE0E0E0)),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              if (transactions.length > 10)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.balance,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      icon: const Icon(Icons.list_alt),
                      label: const Text('View All Transactions'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                        );
                      },
                    ),
                  ),
                ),
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
