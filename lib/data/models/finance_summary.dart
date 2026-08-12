import 'package:flutter/foundation.dart';

import '../../core/utils/app_dates.dart';
import 'monthly_budget.dart';
import 'tx_category.dart';

/// One row of the category breakdown.
@immutable
class CategorySpend {
  const CategorySpend({
    required this.category,
    required this.total,
    required this.count,
    required this.share,
  });

  final TxCategory category;

  /// Positive magnitude spent in this category.
  final double total;

  /// How many transactions make up [total].
  final int count;

  /// Fraction of the period's total spending, `0.0`–`1.0`.
  final double share;
}

/// Spending on a single day, used by the month ruler under the hero figure.
@immutable
class DailySpend {
  const DailySpend({
    required this.day,
    required this.total,
    required this.isToday,
    required this.isFuture,
  });

  final DateTime day;
  final double total;
  final bool isToday;

  /// Days that have not happened yet are drawn as empty ticks.
  final bool isFuture;
}

/// Everything the dashboard needs, computed once per data change.
///
/// Keeping the arithmetic here rather than in widgets means the numbers on the
/// dashboard, the reports screen, and the budget screen can never disagree.
@immutable
class FinanceSummary {
  const FinanceSummary({
    required this.month,
    required this.totalBalance,
    required this.monthIncome,
    required this.monthExpense,
    required this.todayExpense,
    required this.transactionCount,
    required this.categoryBreakdown,
    required this.dailySpend,
    this.budget,
  });

  factory FinanceSummary.empty(DateTime month) => FinanceSummary(
        month: month,
        totalBalance: 0,
        monthIncome: 0,
        monthExpense: 0,
        todayExpense: 0,
        transactionCount: 0,
        categoryBreakdown: const <CategorySpend>[],
        dailySpend: const <DailySpend>[],
      );

  /// The month these figures describe.
  final DateTime month;

  /// All income minus all expenses, across every month on record.
  final double totalBalance;

  final double monthIncome;
  final double monthExpense;
  final double todayExpense;

  /// Transactions recorded in [month].
  final int transactionCount;

  /// Expense categories for [month], largest first.
  final List<CategorySpend> categoryBreakdown;

  /// One entry per day of [month], in order.
  final List<DailySpend> dailySpend;

  final MonthlyBudget? budget;

  double get netThisMonth => monthIncome - monthExpense;

  bool get hasBudget => budget != null && budget!.amount > 0;

  double get budgetAmount => budget?.amount ?? 0;

  /// How much of the allowance is left. Goes negative once overspent, which the
  /// UI shows rather than hiding.
  double get budgetRemaining => budgetAmount - monthExpense;

  /// `0.0`–`1.0`+ share of the allowance used. `0` when no budget is set.
  double get budgetUsedRatio {
    if (!hasBudget) return 0;
    return monthExpense / budgetAmount;
  }

  /// Clamped for drawing progress tracks.
  double get budgetUsedRatioClamped => budgetUsedRatio.clamp(0.0, 1.0);

  /// Divides by days elapsed, not by the whole month, so early in the month the
  /// figure is not misleadingly small.
  double get averageDailyExpense {
    final int days = AppDates.elapsedDaysInMonth(month);
    if (days <= 0) return 0;
    return monthExpense / days;
  }

  CategorySpend? get topCategory =>
      categoryBreakdown.isEmpty ? null : categoryBreakdown.first;

  /// The busiest day's spend — sets the scale for the month ruler.
  double get peakDailySpend {
    double peak = 0;
    for (final DailySpend d in dailySpend) {
      if (d.total > peak) peak = d.total;
    }
    return peak;
  }

  bool get isEmpty => transactionCount == 0;
}
