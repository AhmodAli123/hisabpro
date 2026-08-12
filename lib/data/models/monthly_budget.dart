import 'package:flutter/foundation.dart';

/// A spending allowance for one calendar month.
///
/// Phase 1 reads this to show "Remaining" on the dashboard; editing budgets
/// arrives in Phase 3.
@immutable
class MonthlyBudget {
  const MonthlyBudget({
    required this.id,
    required this.year,
    required this.month,
    required this.amount,
  });

  MonthlyBudget.forMonth(DateTime date, this.amount)
      : id = 'budget-${date.year}-${date.month.toString().padLeft(2, '0')}',
        year = date.year,
        month = date.month;

  final String id;
  final int year;

  /// 1–12.
  final int month;

  final double amount;

  /// `2026-08` — handy as a map key and as a stable storage key.
  String get periodKey => '$year-${month.toString().padLeft(2, '0')}';

  bool matches(DateTime date) => date.year == year && date.month == month;

  MonthlyBudget copyWith({double? amount}) => MonthlyBudget(
        id: id,
        year: year,
        month: month,
        amount: amount ?? this.amount,
      );

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'year': year,
        'month': month,
        'amount': amount,
      };

  static MonthlyBudget fromMap(Map<String, Object?> map) {
    final int year = (map['year'] as num?)?.toInt() ?? DateTime.now().year;
    final int month = (map['month'] as num?)?.toInt() ?? DateTime.now().month;
    return MonthlyBudget(
      id: (map['id'] as String?) ??
          'budget-$year-${month.toString().padLeft(2, '0')}',
      year: year,
      month: month,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MonthlyBudget &&
      other.id == id &&
      other.year == year &&
      other.month == month &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(id, year, month, amount);

  @override
  String toString() => 'MonthlyBudget($periodKey, $amount)';
}
