import 'package:flutter/foundation.dart';

import '../../core/utils/id_generator.dart';
import 'payment_method.dart';
import 'transaction_kind.dart';
import 'tx_category.dart';

/// A single income or expense entry.
///
/// Named `MoneyTransaction` rather than `Transaction` so it never collides with
/// the database `Transaction` type introduced in Phase 2.
///
/// [amount] is always a positive magnitude; direction lives in [kind]. Use
/// [signedAmount] when summing mixed lists.
@immutable
class MoneyTransaction {
  const MoneyTransaction({
    required this.id,
    required this.kind,
    required this.amount,
    required this.categoryId,
    required this.dateTime,
    this.note = '',
    this.paymentMethod = PaymentMethod.cash,
    this.receiptPath,
    this.userId,
    this.updatedAt,
    this.syncStatus,
  });

  /// Convenience constructor for entries created on the device.
  MoneyTransaction.create({
    required this.kind,
    required double amount,
    required this.categoryId,
    required this.dateTime,
    this.note = '',
    this.paymentMethod = PaymentMethod.cash,
    this.receiptPath,
    this.userId,
    this.updatedAt,
    this.syncStatus,
  })  : id = IdGenerator.next(),
        amount = amount.abs();

  final String id;
  final TransactionKind kind;

  /// Positive magnitude in the user's currency.
  final double amount;

  /// References [TxCategory.id].
  final String categoryId;

  final DateTime dateTime;

  final String note;

  final PaymentMethod paymentMethod;

  /// Set from Phase 4 onward when a receipt image is attached.
  final String? receiptPath;

  /// The Supabase auth user id owning this record (optional for local-only)
  final String? userId;

  /// Milliseconds since epoch of the last update (local or remote).
  final int? updatedAt;

  /// Optional sync status: 'synced', 'pending', 'conflict', etc.
  final String? syncStatus;

  /// Negative for expenses, positive for income.
  double get signedAmount => amount * kind.sign;

  TxCategory get category => CategoryCatalog.byId(categoryId);

  bool get isIncome => kind.isIncome;

  bool get isExpense => kind.isExpense;

  bool get hasNote => note.trim().isNotEmpty;

  bool get hasReceipt => (receiptPath ?? '').isNotEmpty;

  /// The line shown under the amount in a list row: the note if there is one,
  /// otherwise the category name.
  String get displayTitle => hasNote ? note.trim() : category.label;

  MoneyTransaction copyWith({
    String? id,
    TransactionKind? kind,
    double? amount,
    String? categoryId,
    DateTime? dateTime,
    String? note,
    PaymentMethod? paymentMethod,
    String? receiptPath,
    bool clearReceipt = false,
    String? userId,
    int? updatedAt,
    String? syncStatus,
  }) {
    return MoneyTransaction(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      amount: (amount ?? this.amount).abs(),
      categoryId: categoryId ?? this.categoryId,
      dateTime: dateTime ?? this.dateTime,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptPath: clearReceipt ? null : (receiptPath ?? this.receiptPath),
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  /// Shaped for a relational row so Phase 2 can persist it unchanged.
  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'kind': kind.id,
        'amount': amount,
        'category_id': categoryId,
        'date_time': dateTime.millisecondsSinceEpoch,
        'note': note,
        'payment_method': paymentMethod.id,
      'receipt_path': receiptPath,
      'user_id': userId,
      'updated_at': updatedAt,
      'sync_status': syncStatus,
      };

  /// Tolerant of missing or wrongly typed fields so one bad row can never take
  /// the whole ledger down.
  static MoneyTransaction fromMap(Map<String, Object?> map) {
    return MoneyTransaction(
      id: (map['id'] as String?) ?? IdGenerator.next(),
      kind: TransactionKind.fromId(map['kind'] as String?),
      amount: _toDouble(map['amount']),
      categoryId: (map['category_id'] as String?) ?? CategoryCatalog.unknown.id,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (map['date_time'] as num?)?.toInt() ?? 0,
      ),
      note: (map['note'] as String?) ?? '',
      paymentMethod: PaymentMethod.fromId(map['payment_method'] as String?),
      receiptPath: map['receipt_path'] as String?,
      userId: map['user_id'] as String?,
      updatedAt: (map['updated_at'] as num?)?.toInt(),
      syncStatus: map['sync_status'] as String?,
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble().abs();
    if (value is String) return (double.tryParse(value) ?? 0).abs();
    return 0;
  }

  @override
  bool operator ==(Object other) =>
      other is MoneyTransaction &&
      other.id == id &&
      other.kind == kind &&
      other.amount == amount &&
      other.categoryId == categoryId &&
      other.dateTime == dateTime &&
      other.note == note &&
      other.paymentMethod == paymentMethod &&
      other.receiptPath == receiptPath;

  @override
  int get hashCode => Object.hash(
        id,
        kind,
        amount,
        categoryId,
        dateTime,
        note,
        paymentMethod,
      receiptPath,
      userId,
      updatedAt,
      syncStatus,
      );

  @override
  String toString() =>
      'MoneyTransaction($id, ${kind.id}, $amount, $categoryId, $dateTime)';
}
