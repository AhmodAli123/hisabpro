/// Whether money came in or went out.
///
/// Amounts are stored as a positive magnitude and this enum supplies the sign,
/// which keeps sums unambiguous and makes filtering trivial.
enum TransactionKind {
  income('income', 'Income'),
  expense('expense', 'Expense');

  const TransactionKind(this.id, this.label);

  /// Stable string persisted to storage. Never derive this from `name` at a
  /// call site — the explicit id survives any future renaming of the enum.
  final String id;

  final String label;

  bool get isIncome => this == TransactionKind.income;

  bool get isExpense => this == TransactionKind.expense;

  /// `+1` for income, `-1` for expense.
  int get sign => isIncome ? 1 : -1;

  static TransactionKind fromId(String? id) {
    for (final TransactionKind k in TransactionKind.values) {
      if (k.id == id) return k;
    }
    return TransactionKind.expense;
  }
}
