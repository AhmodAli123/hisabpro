import '../../core/utils/app_dates.dart';
import '../datasources/transaction_data_source.dart';
import '../models/finance_summary.dart';
import '../models/money_transaction.dart';
import '../models/monthly_budget.dart';
import '../models/report_data.dart';
import '../models/tx_category.dart';
import '../models/transaction_kind.dart';

class FinanceRepository {
  FinanceRepository(this._dataSource);

  final TransactionDataSource _dataSource;

  Future<FinanceSummary> fetchFinanceSummary({DateTime? month}) async {
    final DateTime monthReference = month ?? DateTime.now();
    final DateTime monthStart = AppDates.startOfMonth(monthReference);
    final DateTime today = DateTime.now();

    final List<MoneyTransaction> transactions = await _dataSource.fetchTransactions();
    final List<MonthlyBudget> budgets = await _dataSource.fetchBudgets();

    final double totalBalance = transactions.fold(
      0,
      (double running, MoneyTransaction transaction) =>
          running + transaction.signedAmount,
    );

    final List<MoneyTransaction> monthTransactions = transactions.where(
      (MoneyTransaction transaction) =>
          AppDates.isSameMonth(transaction.dateTime, monthStart),
    ).toList();

    final double monthIncome = monthTransactions.fold(
      0,
      (double running, MoneyTransaction transaction) =>
          running + (transaction.isIncome ? transaction.amount : 0),
    );

    final double monthExpense = monthTransactions.fold(
      0,
      (double running, MoneyTransaction transaction) =>
          running + (transaction.isExpense ? transaction.amount : 0),
    );

    final double todayExpense = monthTransactions.fold(
      0,
      (double running, MoneyTransaction transaction) {
        if (transaction.isExpense && AppDates.isSameDay(transaction.dateTime, today)) {
          return running + transaction.amount;
        }
        return running;
      },
    );

    final MonthlyBudget? budget = budgets.cast<MonthlyBudget?>().firstWhere(
          (MonthlyBudget? item) => item != null && item.matches(monthStart),
          orElse: () => null,
        );

    final List<CategorySpend> categoryBreakdown = _buildCategoryBreakdown(
      monthTransactions,
      monthExpense,
    );

    final List<DailySpend> dailySpend = _buildDailySpend(
      monthStart,
      monthTransactions,
      today,
    );

    return FinanceSummary(
      month: monthStart,
      totalBalance: totalBalance,
      monthIncome: monthIncome,
      monthExpense: monthExpense,
      todayExpense: todayExpense,
      transactionCount: monthTransactions.length,
      categoryBreakdown: categoryBreakdown,
      dailySpend: dailySpend,
      budget: budget,
    );
  }

  Future<List<MoneyTransaction>> fetchTransactions({TransactionKind? kind}) async {
    final List<MoneyTransaction> transactions = await _dataSource.fetchTransactions();
    if (kind == null) {
      return transactions;
    }
    return transactions.where((MoneyTransaction transaction) => transaction.kind == kind).toList();
  }

  Future<List<MoneyTransaction>> fetchRecentTransactions(int limit) async {
    final List<MoneyTransaction> transactions = await _dataSource.fetchTransactions();
    return transactions.take(limit).toList();
  }

  Future<void> addTransaction(MoneyTransaction transaction) async {
    await _dataSource.addTransaction(transaction);
  }

  Future<void> updateTransaction(MoneyTransaction transaction) async {
    await _dataSource.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _dataSource.deleteTransaction(id);
  }

  Future<List<MonthlyBudget>> fetchBudgets() async {
    return await _dataSource.fetchBudgets();
  }

  // Recurring transactions
  Future<List<RecurringTransaction>> fetchRecurringTransactions() async {
    return await _dataSource.fetchRecurringTransactions();
  }

  Future<void> addRecurringTransaction(RecurringTransaction transaction) async {
    await _dataSource.addRecurringTransaction(transaction);
  }

  Future<void> updateRecurringTransaction(RecurringTransaction transaction) async {
    await _dataSource.updateRecurringTransaction(transaction);
  }

  Future<void> deleteRecurringTransaction(String id) async {
    await _dataSource.deleteRecurringTransaction(id);
  }

  Future<void> saveBudget(MonthlyBudget budget) async {
    await _dataSource.saveBudget(budget);
  }

  Future<ReportData> fetchReportData({DateTime? month, int comparisonMonths = 3}) async {
    final DateTime monthReference = month ?? DateTime.now();
    final DateTime monthStart = AppDates.startOfMonth(monthReference);
    final DateTime today = DateTime.now();

    final List<MoneyTransaction> transactions = await _dataSource.fetchTransactions();
    final List<MonthlyBudget> budgets = await _dataSource.fetchBudgets();

    final List<MoneyTransaction> monthTransactions = transactions.where(
      (MoneyTransaction transaction) =>
          AppDates.isSameMonth(transaction.dateTime, monthStart),
    ).toList();

    final double monthIncome = monthTransactions.fold(
      0,
      (double running, MoneyTransaction transaction) =>
          running + (transaction.isIncome ? transaction.amount : 0),
    );

    final double monthExpense = monthTransactions.fold(
      0,
      (double running, MoneyTransaction transaction) =>
          running + (transaction.isExpense ? transaction.amount : 0),
    );

    final MonthlyBudget? budget = budgets.cast<MonthlyBudget?>().firstWhere(
          (MonthlyBudget? item) => item != null && item.matches(monthStart),
          orElse: () => null,
        );

    final List<CategorySpend> categoryBreakdown = _buildCategoryBreakdown(
      monthTransactions,
      monthExpense,
    );

    final List<DailySpend> dailySpend = _buildDailySpend(
      monthStart,
      monthTransactions,
      today,
    );

    final List<MonthlyComparison> monthlyComparison = _buildMonthlyComparison(
      transactions,
      monthStart,
      comparisonMonths,
    );

    return ReportData(
      start: monthStart,
      end: AppDates.endOfMonth(monthStart),
      totalIncome: monthIncome,
      totalExpense: monthExpense,
      netBalance: monthIncome - monthExpense,
      averageDailyExpense: monthExpense == 0
          ? 0
          : monthExpense / AppDates.elapsedDaysInMonth(monthStart),
      topCategory: categoryBreakdown.isEmpty ? null : categoryBreakdown.first,
      categoryBreakdown: categoryBreakdown,
      dailySpend: dailySpend,
      monthlyComparison: monthlyComparison,
    );
  }

  List<CategorySpend> _buildCategoryBreakdown(
    List<MoneyTransaction> transactions,
    double totalExpense,
  ) {
    final Map<TxCategory, double> totals = <TxCategory, double>{};

    for (final MoneyTransaction transaction in transactions) {
      if (transaction.isExpense) {
        totals[transaction.category] =
            (totals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    final List<CategorySpend> breakdown = totals.entries
        .map(
          (MapEntry<TxCategory, double> entry) => CategorySpend(
            category: entry.key,
            total: entry.value,
            count: transactions
                .where((MoneyTransaction transaction) =>
                    transaction.isExpense && transaction.category == entry.key)
                .length,
            share: totalExpense == 0 ? 0 : entry.value / totalExpense,
          ),
        )
        .toList();

    breakdown.sort((CategorySpend a, CategorySpend b) =>
        b.total.compareTo(a.total));
    return breakdown;
  }

  List<DailySpend> _buildDailySpend(
    DateTime monthStart,
    List<MoneyTransaction> transactions,
    DateTime today,
  ) {
    final int daysCount = AppDates.daysInMonth(monthStart);
    final List<DailySpend> dailySpend = <DailySpend>[];

    for (int day = 1; day <= daysCount; day += 1) {
      final DateTime date = DateTime(monthStart.year, monthStart.month, day);
      final double total = transactions.fold(
        0,
        (double running, MoneyTransaction transaction) {
          if (AppDates.isSameDay(transaction.dateTime, date) && transaction.isExpense) {
            return running + transaction.amount;
          }
          return running;
        },
      );

      dailySpend.add(
        DailySpend(
          day: date,
          total: total,
          isToday: AppDates.isSameDay(date, today),
          isFuture: date.isAfter(today),
        ),
      );
    }

    return dailySpend;
  }

  List<MonthlyComparison> _buildMonthlyComparison(
    List<MoneyTransaction> transactions,
    DateTime currentMonthStart,
    int comparisonMonths,
  ) {
    final Map<String, MonthlyComparison> totals = <String, MonthlyComparison>{};
    for (int index = comparisonMonths - 1; index >= 0; index -= 1) {
      final DateTime month = DateTime(
        currentMonthStart.year,
        currentMonthStart.month - index,
      );
      totals[AppDates.monthShort(month)] = MonthlyComparison(
        month: month,
        income: 0,
        expense: 0,
      );
    }

    for (final MoneyTransaction transaction in transactions) {
      final DateTime month = AppDates.startOfMonth(transaction.dateTime);
      final String label = AppDates.monthShort(month);
      if (!totals.containsKey(label)) {
        continue;
      }

      final MonthlyComparison current = totals[label]!;
      totals[label] = MonthlyComparison(
        month: current.month,
        income: current.income + (transaction.isIncome ? transaction.amount : 0),
        expense: current.expense + (transaction.isExpense ? transaction.amount : 0),
      );
    }

    return totals.values.toList();
  }
}
