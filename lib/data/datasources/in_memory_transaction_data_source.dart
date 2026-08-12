import '../../core/utils/app_dates.dart';
import '../models/money_transaction.dart';
import '../models/monthly_budget.dart';
import '../models/payment_method.dart';
import '../models/transaction_kind.dart';
import '../models/recurring_transaction.dart';
import 'transaction_data_source.dart';

/// Holds the ledger in memory for Phase 1.
///
/// Entries added here survive navigation and theme changes but not an app
/// restart — Phase 2 replaces this class with a SQLite implementation of the
/// same [TransactionDataSource] interface, and nothing above this file changes.
///
/// It ships seeded with a realistic month so the dashboard, category breakdown,
/// and month ruler can be judged against real-looking numbers.
class InMemoryTransactionDataSource implements TransactionDataSource {
  InMemoryTransactionDataSource({bool seed = true}) {
    if (seed) _seed();
  }

  final Map<String, MoneyTransaction> _transactions =
      <String, MoneyTransaction>{};
  final Map<String, MonthlyBudget> _budgets = <String, MonthlyBudget>{};
  final Map<String, RecurringTransaction> _recurrings = <String, RecurringTransaction>{};

  @override
  Future<List<MoneyTransaction>> fetchTransactions() async {
    final List<MoneyTransaction> all = _transactions.values.toList()
      ..sort((MoneyTransaction a, MoneyTransaction b) {
        final int byDate = b.dateTime.compareTo(a.dateTime);
        if (byDate != 0) return byDate;
        // Stable tiebreak so equal timestamps never reorder between reads.
        return b.id.compareTo(a.id);
      });
    return all;
  }

  @override
  Future<void> addTransaction(MoneyTransaction transaction) async {
    _transactions[transaction.id] = transaction;
  }

  @override
  Future<void> updateTransaction(MoneyTransaction transaction) async {
    if (!_transactions.containsKey(transaction.id)) return;
    _transactions[transaction.id] = transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _transactions.remove(id);
  }

  @override
  Future<List<MonthlyBudget>> fetchBudgets() async =>
      _budgets.values.toList(growable: false);

  @override
  Future<void> saveBudget(MonthlyBudget budget) async {
    _budgets[budget.periodKey] = budget;
  }

  // ---------------------------------------------------------------- recurring

  @override
  Future<List<RecurringTransaction>> fetchRecurringTransactions() async {
    return _recurrings.values.toList(growable: false);
  }

  @override
  Future<void> addRecurringTransaction(RecurringTransaction transaction) async {
    _recurrings[transaction.id] = transaction;
  }

  @override
  Future<void> updateRecurringTransaction(RecurringTransaction transaction) async {
    if (!_recurrings.containsKey(transaction.id)) return;
    _recurrings[transaction.id] = transaction;
  }

  @override
  Future<void> deleteRecurringTransaction(String id) async {
    _recurrings.remove(id);
  }

  // ---------------------------------------------------------------- seed data

  void _seed() {
    final DateTime now = DateTime.now();
    final DateTime thisMonth = AppDates.startOfMonth(now);
    final DateTime lastMonth = DateTime(now.year, now.month - 1);

    _budgets[MonthlyBudget.forMonth(thisMonth, 5000).periodKey] =
        MonthlyBudget.forMonth(thisMonth, 5000);
    _budgets[MonthlyBudget.forMonth(lastMonth, 5000).periodKey] =
        MonthlyBudget.forMonth(lastMonth, 5000);

    // Entries dated later than today are skipped, so the seed stays in the
    // past no matter which day of the month the app is first opened.
    for (final _Seed s in _currentMonthSeed) {
      _addSeed(s, thisMonth, notAfter: now);
    }
    for (final _Seed s in _lastMonthSeed) {
      _addSeed(s, lastMonth);
    }
    for (final _Seed s in _todaySeed) {
      _addSeed(s, AppDates.startOfDay(now), dayOverride: 1);
    }
  }

  void _addSeed(
    _Seed seed,
    DateTime monthStart, {
    DateTime? notAfter,
    int? dayOverride,
  }) {
    final int lastDay = AppDates.daysInMonth(monthStart);
    final int day = (dayOverride ?? seed.day).clamp(1, lastDay);
    final DateTime when = DateTime(
      monthStart.year,
      monthStart.month,
      dayOverride != null ? monthStart.day : day,
      seed.hour,
      seed.minute,
    );
    if (notAfter != null && when.isAfter(notAfter)) return;

    final MoneyTransaction tx = MoneyTransaction.create(
      kind: seed.kind,
      amount: seed.amount,
      categoryId: seed.categoryId,
      dateTime: when,
      note: seed.note,
      paymentMethod: seed.method,
    );
    _transactions[tx.id] = tx;
  }

  static const List<_Seed> _currentMonthSeed = <_Seed>[
    _Seed(1, 9, 5, TransactionKind.income, 'inc_salary', 8200,
        'Monthly salary', PaymentMethod.bank),
    _Seed(1, 10, 20, TransactionKind.expense, 'exp_rent', 1200, 'Rent',
        PaymentMethod.bank),
    _Seed(2, 18, 40, TransactionKind.expense, 'exp_food', 245.50,
        'Weekly groceries', PaymentMethod.card),
    _Seed(3, 8, 15, TransactionKind.expense, 'exp_transport', 100.50,
        'Bus card top-up', PaymentMethod.cash),
    _Seed(4, 20, 10, TransactionKind.expense, 'exp_bills', 310.75,
        'Electricity', PaymentMethod.online),
    _Seed(5, 13, 30, TransactionKind.expense, 'exp_food', 42, 'Lunch',
        PaymentMethod.card),
    _Seed(6, 17, 45, TransactionKind.expense, 'exp_shopping', 289, 'Shoes',
        PaymentMethod.card),
    _Seed(7, 11, 0, TransactionKind.expense, 'exp_health', 150, 'Pharmacy',
        PaymentMethod.cash),
    _Seed(8, 19, 25, TransactionKind.expense, 'exp_food', 88.25, 'Groceries',
        PaymentMethod.card),
    _Seed(9, 7, 50, TransactionKind.expense, 'exp_transport', 45, 'Taxi',
        PaymentMethod.cash),
    _Seed(10, 14, 0, TransactionKind.income, 'inc_freelance', 650,
        'Logo project', PaymentMethod.online),
    _Seed(11, 21, 15, TransactionKind.expense, 'exp_entertainment', 75,
        'Cinema', PaymentMethod.card),
    _Seed(12, 12, 5, TransactionKind.expense, 'exp_bills', 120,
        'Mobile and internet', PaymentMethod.online),
    _Seed(13, 16, 30, TransactionKind.expense, 'exp_education', 400,
        'Online course', PaymentMethod.card),
    _Seed(14, 18, 55, TransactionKind.expense, 'exp_food', 132.50,
        'Groceries', PaymentMethod.card),
    _Seed(15, 9, 40, TransactionKind.expense, 'exp_transport', 70, 'Fuel',
        PaymentMethod.cash),
    _Seed(16, 15, 10, TransactionKind.expense, 'exp_shopping', 96,
        'Household items', PaymentMethod.card),
    _Seed(18, 13, 20, TransactionKind.expense, 'exp_food', 64, 'Lunch',
        PaymentMethod.cash),
    _Seed(20, 10, 0, TransactionKind.expense, 'exp_bills', 85, 'Water',
        PaymentMethod.online),
    _Seed(22, 19, 30, TransactionKind.expense, 'exp_food', 158.75,
        'Groceries', PaymentMethod.card),
    _Seed(24, 8, 30, TransactionKind.expense, 'exp_transport', 55,
        'Bus card top-up', PaymentMethod.cash),
    _Seed(26, 20, 45, TransactionKind.expense, 'exp_entertainment', 110,
        'Family outing', PaymentMethod.card),
  ];

  static const List<_Seed> _lastMonthSeed = <_Seed>[
    _Seed(1, 9, 10, TransactionKind.income, 'inc_salary', 8200,
        'Monthly salary', PaymentMethod.bank),
    _Seed(1, 10, 30, TransactionKind.expense, 'exp_rent', 1200, 'Rent',
        PaymentMethod.bank),
    _Seed(3, 18, 20, TransactionKind.expense, 'exp_food', 320, 'Groceries',
        PaymentMethod.card),
    _Seed(6, 11, 45, TransactionKind.expense, 'exp_bills', 285, 'Electricity',
        PaymentMethod.online),
    _Seed(9, 16, 15, TransactionKind.expense, 'exp_shopping', 410, 'Clothes',
        PaymentMethod.card),
    _Seed(12, 8, 40, TransactionKind.expense, 'exp_transport', 180, 'Fuel',
        PaymentMethod.cash),
    _Seed(15, 19, 5, TransactionKind.expense, 'exp_food', 265, 'Groceries',
        PaymentMethod.card),
    _Seed(18, 10, 25, TransactionKind.expense, 'exp_health', 95,
        'Doctor visit', PaymentMethod.cash),
    _Seed(20, 12, 0, TransactionKind.income, 'inc_bonus', 500,
        'Performance bonus', PaymentMethod.bank),
    _Seed(22, 7, 30, TransactionKind.expense, 'exp_travel', 780,
        'Flight home', PaymentMethod.card),
    _Seed(25, 21, 10, TransactionKind.expense, 'exp_entertainment', 140,
        'Cinema', PaymentMethod.card),
    _Seed(27, 18, 50, TransactionKind.expense, 'exp_food', 210, 'Groceries',
        PaymentMethod.card),
    _Seed(29, 9, 15, TransactionKind.expense, 'exp_bills', 130,
        'Mobile and internet', PaymentMethod.online),
  ];

  static const List<_Seed> _todaySeed = <_Seed>[
    _Seed(1, 8, 20, TransactionKind.expense, 'exp_transport', 12,
        'Bus fare', PaymentMethod.cash),
    _Seed(1, 13, 15, TransactionKind.expense, 'exp_food', 22, 'Lunch',
        PaymentMethod.cash),
    _Seed(1, 19, 40, TransactionKind.expense, 'exp_food', 51.50,
        'Dinner groceries', PaymentMethod.card),
  ];
}

/// Compact description of one seeded entry.
class _Seed {
  const _Seed(
    this.day,
    this.hour,
    this.minute,
    this.kind,
    this.categoryId,
    this.amount,
    this.note,
    this.method,
  );

  final int day;
  final int hour;
  final int minute;
  final TransactionKind kind;
  final String categoryId;
  final double amount;
  final String note;
  final PaymentMethod method;
}
