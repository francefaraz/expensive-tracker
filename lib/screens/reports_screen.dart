import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/db_helper.dart';
import '../utils/currency_helper.dart';
import '../utils/format_helper.dart';
import 'package:provider/provider.dart';
import '../utils/currency_provider.dart';
import '../utils/app_colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<List<TransactionModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = DBHelper.getTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<CurrencyProvider>(context).currency;
    final currencyFormat = NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions yet.', style: TextStyle(color: AppColors.textPrimary)));
          }
          final transactions = snapshot.data!;

          // Pie chart data
          final Map<String, double> categoryTotals = {};
          for (var txn in transactions) {
            if (txn.type == 'expense') {
              categoryTotals[txn.category] = (categoryTotals[txn.category] ?? 0) + txn.amount;
            }
          }
          final pieSections = <PieChartSectionData>[];
          final colors = [AppColors.income, AppColors.expense, AppColors.balance, AppColors.yellow, AppColors.green, AppColors.textSecondary];
          int colorIdx = 0;
          categoryTotals.forEach((cat, amt) {
            pieSections.add(PieChartSectionData(
              color: colors[colorIdx % colors.length],
              value: amt,
              title: '',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ));
            colorIdx++;
          });

          // Line chart data (income/expense over months)
          final Map<String, double> incomeByMonth = {};
          final Map<String, double> expenseByMonth = {};
          for (var txn in transactions) {
            final month = txn.date.substring(0, 7); // "YYYY-MM"
            if (txn.type == 'income') {
              incomeByMonth[month] = (incomeByMonth[month] ?? 0) + txn.amount;
            } else {
              expenseByMonth[month] = (expenseByMonth[month] ?? 0) + txn.amount;
            }
          }
          final months = {...incomeByMonth.keys, ...expenseByMonth.keys}.toList()..sort();
          final incomeSpots = months.asMap().entries.map((e) => FlSpot(e.key.toDouble(), incomeByMonth[e.value] ?? 0)).toList();
          final expenseSpots = months.asMap().entries.map((e) => FlSpot(e.key.toDouble(), expenseByMonth[e.value] ?? 0)).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 4,
                    shadowColor: AppColors.balance.withOpacity(0.08),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Category-wise Spending', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 180,
                            child: PieChart(
                              PieChartData(
                                sections: pieSections,
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            children: categoryTotals.keys.map((cat) {
                              final idx = categoryTotals.keys.toList().indexOf(cat);
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    color: colors[idx % colors.length],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(cat, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                                  const SizedBox(width: 4),
                                  Text(formatCurrency(categoryTotals[cat] ?? 0, currency), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                          const Text('Income vs Expense (Monthly)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: incomeSpots,
                                    isCurved: true,
                                    color: AppColors.income,
                                    barWidth: 3,
                                    dotData: FlDotData(show: false),
                                  ),
                                  LineChartBarData(
                                    spots: expenseSpots,
                                    isCurved: true,
                                    color: AppColors.expense,
                                    barWidth: 3,
                                    dotData: FlDotData(show: false),
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) {
                                      return Text(formatCurrency(value, currency), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary));
                                    }),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final idx = value.toInt();
                                        if (idx >= 0 && idx < months.length) {
                                          return Text(months[idx].substring(5), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary));
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(show: false),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(Icons.show_chart, color: AppColors.income, size: 16),
                              SizedBox(width: 4),
                              Text('Income', style: TextStyle(color: AppColors.income)),
                              SizedBox(width: 16),
                              Icon(Icons.show_chart, color: AppColors.expense, size: 16),
                              SizedBox(width: 4),
                              Text('Expense', style: TextStyle(color: AppColors.expense)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
