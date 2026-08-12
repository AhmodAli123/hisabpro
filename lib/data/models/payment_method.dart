import 'package:flutter/material.dart';

/// How a transaction was paid for or received.
enum PaymentMethod {
  cash('cash', 'Cash', Icons.payments_outlined),
  card('card', 'Card', Icons.credit_card_outlined),
  bank('bank', 'Bank', Icons.account_balance_outlined),
  online('online', 'Online', Icons.language_outlined),
  other('other', 'Other', Icons.more_horiz_outlined);

  const PaymentMethod(this.id, this.label, this.icon);

  /// Stable string persisted to storage.
  final String id;

  final String label;

  /// Held as a `const IconData` rather than a code point so icon tree-shaking
  /// keeps working. Storage only ever needs [id].
  final IconData icon;

  static PaymentMethod fromId(String? id) {
    for (final PaymentMethod m in PaymentMethod.values) {
      if (m.id == id) return m;
    }
    return PaymentMethod.cash;
  }
}
