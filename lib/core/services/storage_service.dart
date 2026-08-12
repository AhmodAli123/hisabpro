import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/money_transaction.dart';
import '../../data/models/monthly_budget.dart';
import '../../data/models/recurring_transaction.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  Future<Directory> getAppDirectory() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return dir;
  }

  Future<String> writeCsvTransactions(List<MoneyTransaction> transactions, String filename) async {
    final List<List<dynamic>> rows = <List<dynamic>>[];
    rows.add(['id','kind','amount','categoryId','dateTime','note','paymentMethod','receiptPath']);
    for (final tx in transactions) {
      rows.add([
        tx.id,
        tx.kind.id,
        tx.amount,
        tx.categoryId,
        tx.dateTime.toIso8601String(),
        tx.note,
        tx.paymentMethod.id,
        tx.receiptPath ?? '',
      ]);
    }

    final String csv = const ListToCsvConverter().convert(rows);
    final Directory dir = await getAppDirectory();
    final File file = File('${dir.path}/$filename');
    await file.writeAsString(csv);
    return file.path;
  }

  Future<String> writeJsonBackup({
    required List<MoneyTransaction> transactions,
    required List<MonthlyBudget> budgets,
    required List<RecurringTransaction> recurrings,
    required String filename,
  }) async {
    final Map<String, dynamic> dump = {
      'transactions': transactions.map((t) => t.toMap()).toList(),
      'budgets': budgets.map((b) => b.toMap()).toList(),
      'recurrings': recurrings.map((r) => r.toMap()).toList(),
    };
    final String json = jsonEncode(dump);
    final Directory dir = await getAppDirectory();
    final File file = File('${dir.path}/$filename');
    await file.writeAsString(json);
    return file.path;
  }

  Future<Map<String, dynamic>> readJsonBackup(File file) async {
    final String contents = await file.readAsString();
    return jsonDecode(contents) as Map<String, dynamic>;
  }
}
