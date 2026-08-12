import 'package:flutter/material.dart';

import 'transaction_kind.dart';

/// A spending or earning category.
///
/// Modelled as data rather than an enum because Phase 2 lets the user manage
/// their own categories; the seeded set in [CategoryCatalog] is simply the
/// starting content.
@immutable
class TxCategory {
  const TxCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.kind,
  });

  /// Stable, kind-prefixed id — `exp_food`, `inc_salary`. Transactions store
  /// only this, never the label, so renaming a category never orphans data.
  final String id;

  final String label;

  /// A `const IconData` so icon tree-shaking is preserved.
  final IconData icon;

  final TransactionKind kind;

  @override
  bool operator ==(Object other) => other is TxCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TxCategory($id)';
}

/// The categories HisabPro ships with.
abstract final class CategoryCatalog {
  static const List<TxCategory> expense = <TxCategory>[
    TxCategory(
      id: 'exp_food',
      label: 'Food',
      icon: Icons.restaurant_outlined,
      kind: TransactionKind.expense,
    ),
    TxCategory(
      id: 'exp_transport',
      label: 'Transport',
      icon: Icons.directions_bus_outlined,
      kind: TransactionKind.expense,
    ),
    TxCategory(
      id: 'exp_shopping',
      label: 'Shopping',
      icon: Icons.shopping_bag_outlined,
      kind: TransactionKind.expense,
    ),
    TxCategory(
      id: 'exp_rent',
      label: 'Rent',
      icon: Icons.home_outlined,
      kind: TransactionKind.expense,
    ),
    TxCategory(
      id: 'exp_bills',
      label: 'Bills',
      icon: Icons.receipt_long_outlined,
      kind: TransactionKind.expense,
    ),
    TxCategory(
      id: 'exp_health',
      label: 'Health',
      icon: Icons.medical_services_outlined,
      kind: TransactionKind.expense,
    ),
    TxCategory(
      id: 'exp_education',
      label: 'Education',
      icon: Icons.school_outlined,
      kind: TransactionKind.expense,
    ),
    TxCategory(
      id: 'exp_travel',
      label: 'Travel',
      icon: Icons.flight_outlined,
      kind: TransactionKind.expense,
    ),
    TxCategory(
      id: 'exp_entertainment',
      label: 'Entertainment',
      icon: Icons.movie_outlined,
      kind: TransactionKind.expense,
    ),
    TxCategory(
      id: 'exp_other',
      label: 'Other',
      icon: Icons.category_outlined,
      kind: TransactionKind.expense,
    ),
  ];

  static const List<TxCategory> income = <TxCategory>[
    TxCategory(
      id: 'inc_salary',
      label: 'Salary',
      icon: Icons.work_outline,
      kind: TransactionKind.income,
    ),
    TxCategory(
      id: 'inc_business',
      label: 'Business',
      icon: Icons.storefront_outlined,
      kind: TransactionKind.income,
    ),
    TxCategory(
      id: 'inc_freelance',
      label: 'Freelance',
      icon: Icons.computer_outlined,
      kind: TransactionKind.income,
    ),
    TxCategory(
      id: 'inc_bonus',
      label: 'Bonus',
      icon: Icons.card_giftcard_outlined,
      kind: TransactionKind.income,
    ),
    TxCategory(
      id: 'inc_other',
      label: 'Other',
      icon: Icons.savings_outlined,
      kind: TransactionKind.income,
    ),
  ];

  /// Shown when a transaction references a category that no longer exists.
  static const TxCategory unknown = TxCategory(
    id: 'unknown',
    label: 'Uncategorised',
    icon: Icons.help_outline,
    kind: TransactionKind.expense,
  );

  static List<TxCategory> get all => <TxCategory>[...expense, ...income];

  static List<TxCategory> forKind(TransactionKind kind) =>
      kind.isIncome ? income : expense;

  static final Map<String, TxCategory> _byId = <String, TxCategory>{
    for (final TxCategory c in all) c.id: c,
  };

  /// Never returns null, so list rows always have something to render.
  static TxCategory byId(String? id) {
    if (id == null) return unknown;
    return _byId[id] ?? unknown;
  }
}
