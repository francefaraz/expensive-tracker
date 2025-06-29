import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class ExpenseBarChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  final List<String> categories;

  const ExpenseBarChart({Key? key, required this.transactions, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate total expense per category
    final Map<String, double> data = {for (var c in categories) c: 0};
    for (var txn in transactions) {
      if (txn.type == 'expense') {
        data[txn.category] = (data[txn.category] ?? 0) + txn.amount;
      }
    }
    final barGroups = data.entries.map((e) {
      return BarChartGroupData(
        x: categories.indexOf(e.key),
        barRods: [
          BarChartRodData(
            toY: e.value,
            color: Colors.redAccent,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < categories.length) {
                    return Text(categories[idx], style: const TextStyle(fontSize: 10));
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
    );
  }
}
