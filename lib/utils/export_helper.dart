import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';

class ExportHelper {
  static Future<String> exportTransactionsToCSV(List<TransactionModel> transactions) async {
    List<List<dynamic>> rows = [
      [
        'ID',
        'Type',
        'Title',
        'Amount',
        'Payment Method',
        'Category',
        'Date',
        'Note',
        'Tag'
      ]
    ];

    for (var txn in transactions) {
      rows.add([
        txn.id ?? '',
        txn.type,
        txn.title,
        txn.amount,
        txn.paymentMethod,
        txn.category,
        txn.date,
        txn.note ?? '',
        txn.tag ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/transactions_export.csv';
    final file = File(path);
    await file.writeAsString(csv);

    return path; // Return the file path
  }
}
