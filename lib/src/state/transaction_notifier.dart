import 'package:flutter/material.dart';

import '../../data/models/money_transaction.dart';
import '../../data/models/tx_category.dart';
import '../../data/repository/finance_repository.dart';
import '../../data/models/transaction_kind.dart';
import '../../data/models/payment_method.dart';

enum TransactionKindFilter { all, income, expense }

class TransactionListNotifier extends ChangeNotifier {
  TransactionListNotifier(this._repository, {required this.kind});

  final FinanceRepository _repository;
  final TransactionKind kind;

  List<MoneyTransaction> transactions = <MoneyTransaction>[];
  String searchQuery = '';
  String? categoryId;
  double? minAmount;
  double? maxAmount;
  String? paymentMethodId;
  TransactionKindFilter kindFilter = TransactionKindFilter.all;

  bool isLoading = true;
  String? errorMessage;

  Future<void> load() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      transactions = await _repository.fetchTransactions(
        kind: kind,
      );
    } catch (error, stackTrace) {
      errorMessage = error.toString();
      transactions = <MoneyTransaction>[];
      debugPrint('Failed to load transactions: $error\n$stackTrace');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<MoneyTransaction> get filteredTransactions {
    final String normalizedQuery = searchQuery.trim().toLowerCase();
    return transactions.where((MoneyTransaction transaction) {
      final bool matchesCategory = categoryId == null || categoryId!.isEmpty
        ? true
        : transaction.categoryId == categoryId;
      final bool matchesQuery = normalizedQuery.isEmpty
        ? true
        : transaction.displayTitle.toLowerCase().contains(normalizedQuery) ||
          transaction.category.label.toLowerCase().contains(normalizedQuery);
      final bool matchesMin = minAmount == null ? true : transaction.amount >= minAmount!;
      final bool matchesMax = maxAmount == null ? true : transaction.amount <= maxAmount!;
      final bool matchesPayment = paymentMethodId == null || paymentMethodId!.isEmpty
        ? true
        : transaction.paymentMethod.id == paymentMethodId;
      final bool matchesKind = kindFilter == TransactionKindFilter.all
        ? true
        : (kindFilter == TransactionKindFilter.income ? transaction.isIncome : transaction.isExpense);

      return matchesCategory && matchesQuery && matchesMin && matchesMax && matchesPayment && matchesKind;
    }).toList();
  }

  Future<void> addTransaction(MoneyTransaction transaction) async {
    await _repository.addTransaction(transaction);
    await load();
  }

  Future<void> updateTransaction(MoneyTransaction transaction) async {
    await _repository.updateTransaction(transaction);
    await load();
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
    await load();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setMinAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      minAmount = null;
    } else {
      minAmount = double.tryParse(value.trim());
    }
    notifyListeners();
  }

  void setMaxAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      maxAmount = null;
    } else {
      maxAmount = double.tryParse(value.trim());
    }
    notifyListeners();
  }

  void setPaymentMethodId(String? id) {
    paymentMethodId = id;
    notifyListeners();
  }

  void setKindFilter(TransactionKindFilter f) {
    kindFilter = f;
    notifyListeners();
  }

  void setCategoryId(String? selectedId) {
    categoryId = selectedId;
    notifyListeners();
  }

  List<TxCategory> get categoryOptions => TxCategory.forKind(kind);

  double get totalAmount {
    return filteredTransactions.fold(
      0,
      (double running, MoneyTransaction transaction) => running + transaction.amount,
    );
  }
}
