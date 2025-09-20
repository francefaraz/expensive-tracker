import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/db_helper.dart';
import '../utils/app_colors.dart';
import '../utils/format_helper.dart';
import 'package:provider/provider.dart';
import '../utils/currency_provider.dart';
import '../widgets/banner_ad_widget.dart';

class CreditCardScreen extends StatefulWidget {
  const CreditCardScreen({Key? key}) : super(key: key);

  @override
  State<CreditCardScreen> createState() => _CreditCardScreenState();
}

class _CreditCardScreenState extends State<CreditCardScreen> {
  late Future<List<TransactionModel>> _creditCardTransactionsFuture;
  late Future<double> _creditCardDebtFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _creditCardTransactionsFuture = DBHelper.getCreditCardTransactions();
      _creditCardDebtFuture = DBHelper.getCreditCardDebt();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<CurrencyProvider>(context).currency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Management', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 4,
        shadowColor: AppColors.balance.withOpacity(0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Column(
        children: [
          // Credit Card Debt Summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.balance.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FutureBuilder<double>(
              future: _creditCardDebtFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final debt = snapshot.data ?? 0.0;
                return Column(
                  children: [
                    const Icon(Icons.credit_card, size: 48, color: AppColors.expense),
                    const SizedBox(height: 12),
                    const Text(
                      'Total Credit Card Debt',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency(debt, currency),
                      style: TextStyle(
                        color: debt > 0 ? AppColors.expense : AppColors.income,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (debt > 0) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Unpaid credit card transactions',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          
          // Credit Card Transactions List
          Expanded(
            child: FutureBuilder<List<TransactionModel>>(
              future: _creditCardTransactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_card_off, size: 64, color: AppColors.textSecondary),
                        SizedBox(height: 16),
                        Text(
                          'No Credit Card Transactions',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add transactions with Credit Card payment method',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                final transactions = snapshot.data!;
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final txn = transactions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: AppColors.background,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: txn.isPaidOff ? AppColors.income : AppColors.expense,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: txn.isPaidOff ? AppColors.income : AppColors.expense,
                          child: Icon(
                            txn.isPaidOff ? Icons.check : Icons.credit_card,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          txn.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${txn.category} • ${txn.creditCardName ?? 'Unknown Card'}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            if (txn.note != null && txn.note!.isNotEmpty)
                              Text(
                                txn.note!,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            Text(
                              txn.date.split('T')[0],
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${txn.type == 'income' ? '+' : '-'}${formatCurrency(txn.amount, currency)}',
                              style: TextStyle(
                                color: txn.type == 'income' ? AppColors.income : AppColors.expense,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (txn.isPaidOff)
                              const Text(
                                'PAID',
                                style: TextStyle(
                                  color: AppColors.income,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else
                              const Text(
                                'UNPAID',
                                style: TextStyle(
                                  color: AppColors.expense,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        onTap: () => _showTransactionDetails(txn),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  void _showTransactionDetails(TransactionModel txn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              txn.isPaidOff ? Icons.check_circle : Icons.credit_card,
              color: txn.isPaidOff ? AppColors.income : AppColors.expense,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                txn.title,
                style: const TextStyle(color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Amount', '${txn.type == 'income' ? '+' : '-'}${formatCurrency(txn.amount, Provider.of<CurrencyProvider>(context, listen: false).currency)}'),
            _buildDetailRow('Category', txn.category),
            _buildDetailRow('Credit Card', txn.creditCardName ?? 'Unknown'),
            _buildDetailRow('Date', txn.date.split('T')[0]),
            if (txn.note != null && txn.note!.isNotEmpty)
              _buildDetailRow('Note', txn.note!),
            _buildDetailRow('Status', txn.isPaidOff ? 'Paid Off' : 'Unpaid'),
          ],
        ),
        actions: [
          if (!txn.isPaidOff)
            TextButton(
              onPressed: () => _markAsPaid(txn),
              child: const Text('Mark as Paid', style: TextStyle(color: AppColors.income)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _markAsPaid(TransactionModel txn) async {
    try {
      await DBHelper.markCreditCardPaid(txn.id!);
      Navigator.pop(context); // Close dialog
      _loadData(); // Refresh data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction marked as paid!'),
          backgroundColor: AppColors.income,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
