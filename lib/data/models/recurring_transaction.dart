import 'package:flutter/foundation.dart';

import 'money_transaction.dart';
import 'transaction_kind.dart';

/// Frequency of a recurring transaction.
enum RecurrenceFrequency {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly'),
  yearly('yearly');

  const RecurrenceFrequency(this.id);
  final String id;

  static RecurrenceFrequency fromId(String? id) {
    for (final f in RecurrenceFrequency.values) {
      if (f.id == id) return f;
    }
    return RecurrenceFrequency.monthly;
  }
}

@immutable
class RecurringTransaction {
  const RecurringTransaction({
    required this.id,
    required this.kind,
    required this.amount,
    required this.categoryId,
    required this.startDate,
    required this.frequency,
    this.note = '',
    this.paymentMethod,
    this.active = true,
  });

  RecurringTransaction.create({
    required this.kind,
    required double amount,
    required this.categoryId,
    required this.startDate,
    this.frequency = RecurrenceFrequency.monthly,
    this.note = '',
    this.paymentMethod,
    this.active = true,
  })  : id = 'rec-${DateTime.now().millisecondsSinceEpoch}-${amount.toInt()}',
        amount = amount.abs();

  final String id;
  final TransactionKind kind;
  final double amount;
  final String categoryId;
  final DateTime startDate;
  final RecurrenceFrequency frequency;
  final String note;
  final String? paymentMethod;
  final bool active;

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'kind': kind.id,
        'amount': amount,
        'category_id': categoryId,
        'start_date': startDate.millisecondsSinceEpoch,
        'frequency': frequency.id,
        'note': note,
        'payment_method': paymentMethod,
        'active': active ? 1 : 0,
      };

  static RecurringTransaction fromMap(Map<String, Object?> map) {
    return RecurringTransaction(
      id: (map['id'] as String?) ?? 'rec-${DateTime.now().millisecondsSinceEpoch}',
      kind: TransactionKind.fromId(map['kind'] as String?),
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      categoryId: (map['category_id'] as String?) ?? '',
      startDate: DateTime.fromMillisecondsSinceEpoch((map['start_date'] as num?)?.toInt() ?? 0),
      frequency: RecurrenceFrequency.fromId(map['frequency'] as String?),
      note: (map['note'] as String?) ?? '',
      paymentMethod: map['payment_method'] as String?,
      active: ((map['active'] as num?)?.toInt() ?? 1) == 1,
    );
  }
}
