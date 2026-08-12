import 'package:flutter/foundation.dart';

import 'finance_summary.dart';

@immutable
class MonthlyComparison {
  const MonthlyComparison({
    required this.month,
    required this.income,
    required this.expense,
  });

  final DateTime month;
  final double income;
  final double expense;
}

@immutable
class ReportData {
  const ReportData({
    required this.start,
    required this.end,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.averageDailyExpense,
    required this.topCategory,
    required this.categoryBreakdown,
    required this.dailySpend,
    required this.monthlyComparison,
  });

  final DateTime start;
  final DateTime end;
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final double averageDailyExpense;
  final CategorySpend? topCategory;
  final List<CategorySpend> categoryBreakdown;
  final List<DailySpend> dailySpend;
  final List<MonthlyComparison> monthlyComparison;
}
