import '../models/money_transaction.dart';
import '../models/monthly_budget.dart';
import '../models/recurring_transaction.dart';

/// Storage contract for ledger data.
///
/// The dashboard, lists, and reports only ever talk to this interface. Phase 2
/// adds a SQLite-backed implementation and Phase 5 adds a cloud-syncing one;
/// neither requires a change above the repository layer.
abstract interface class TransactionDataSource {
  /// All transactions, newest first.
  Future<List<MoneyTransaction>> fetchTransactions();

  Future<void> addTransaction(MoneyTransaction transaction);

  Future<void> updateTransaction(MoneyTransaction transaction);

  Future<void> deleteTransaction(String id);

  Future<List<MonthlyBudget>> fetchBudgets();

  /// Inserts, or replaces the budget already stored for the same month.
  Future<void> saveBudget(MonthlyBudget budget);

  // Recurring transactions (Phase 4)
  Future<List<RecurringTransaction>> fetchRecurringTransactions();

  Future<void> addRecurringTransaction(RecurringTransaction transaction);

  Future<void> updateRecurringTransaction(RecurringTransaction transaction);

  Future<void> deleteRecurringTransaction(String id);
}
