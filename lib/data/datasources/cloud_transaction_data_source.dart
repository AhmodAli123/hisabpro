import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/money_transaction.dart';
import '../models/monthly_budget.dart';
import '../models/recurring_transaction.dart';
import 'transaction_data_source.dart';

/// A lightweight Cloud-backed TransactionDataSource for Supabase.
///
/// This is a minimal skeleton: it performs basic fetches and writes for the
/// currently authenticated user. Full offline-first sync, conflict resolution,
/// and storage for receipts are left as follow-ups.
class CloudTransactionDataSource implements TransactionDataSource {
  CloudTransactionDataSource._(this._client);

  final SupabaseClient? _client;

  static Future<CloudTransactionDataSource> create() async {
    // Ensure Supabase has been initialized by SupabaseService earlier.
    final client = Supabase.instance.client;
    return CloudTransactionDataSource._(client);
  }

  String? get _userId => _client?.auth.currentUser?.id;

  @override
  Future<void> addRecurringTransaction(RecurringTransaction transaction) async {
    if (_client == null || _userId == null) return;
    await _client!.from('recurrings').insert({
      'id': transaction.id,
      'user_id': _userId,
      'kind': transaction.kind.id,
      'amount': transaction.amount,
      'category_id': transaction.categoryId,
      'start_date': transaction.startDate.millisecondsSinceEpoch,
      'frequency': transaction.frequency.name,
      'note': transaction.note,
      'next_occurrence': transaction.nextOccurrence?.millisecondsSinceEpoch,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    }).execute();
  }

  @override
  Future<void> addTransaction(MoneyTransaction transaction) async {
    if (_client == null || _userId == null) return;
    await _client!.from('transactions').upsert({
      'id': transaction.id,
      'user_id': _userId,
      'kind': transaction.kind.id,
      'amount': transaction.amount,
      'category_id': transaction.categoryId,
      'date_time': transaction.dateTime.millisecondsSinceEpoch,
      'note': transaction.note,
      'payment_method': transaction.paymentMethod.id,
      'receipt_path': transaction.receiptPath,
      'updated_at': transaction.updatedAt ?? DateTime.now().millisecondsSinceEpoch,
      'sync_status': transaction.syncStatus ?? 'synced',
    }).execute();
  }

  @override
  Future<void> deleteRecurringTransaction(String id) async {
    if (_client == null || _userId == null) return;
    await _client!.from('recurrings').delete().match({'id': id, 'user_id': _userId}).execute();
  }

  @override
  Future<void> deleteTransaction(String id) async {
    if (_client == null || _userId == null) return;
    await _client!.from('transactions').delete().match({'id': id, 'user_id': _userId}).execute();
  }

  @override
  Future<List<MonthlyBudget>> fetchBudgets() async {
    if (_client == null || _userId == null) return <MonthlyBudget>[];
    final res = await _client!.from('budgets').select().eq('user_id', _userId).execute();
    if (res.error != null) return <MonthlyBudget>[];
    final List data = res.data as List? ?? <dynamic>[];
    return data.map((e) => MonthlyBudget.fromMap(Map<String, Object?>.from(e))).toList();
  }

  @override
  Future<List<RecurringTransaction>> fetchRecurringTransactions() async {
    if (_client == null || _userId == null) return <RecurringTransaction>[];
    final res = await _client!.from('recurrings').select().eq('user_id', _userId).order('next_occurrence', ascending: true).execute();
    if (res.error != null) return <RecurringTransaction>[];
    final List data = res.data as List? ?? <dynamic>[];
    return data.map((e) => RecurringTransaction.fromMap(Map<String, Object?>.from(e))).toList();
  }

  @override
  Future<List<MoneyTransaction>> fetchTransactions() async {
    if (_client == null || _userId == null) return <MoneyTransaction>[];
    final res = await _client!.from('transactions').select().eq('user_id', _userId).order('date_time', ascending: false).execute();
    if (res.error != null) return <MoneyTransaction>[];
    final List data = res.data as List? ?? <dynamic>[];
    return data.map((e) => MoneyTransaction.fromMap(Map<String, Object?>.from(e))).toList();
  }

  @override
  Future<void> updateRecurringTransaction(RecurringTransaction transaction) async {
    if (_client == null || _userId == null) return;
    await _client!.from('recurrings').update({
      'kind': transaction.kind.id,
      'amount': transaction.amount,
      'category_id': transaction.categoryId,
      'frequency': transaction.frequency.name,
      'note': transaction.note,
      'next_occurrence': transaction.nextOccurrence?.millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }).match({'id': transaction.id, 'user_id': _userId}).execute();
  }

  @override
  Future<void> updateTransaction(MoneyTransaction transaction) async {
    if (_client == null || _userId == null) return;
    await _client!.from('transactions').update({
      'kind': transaction.kind.id,
      'amount': transaction.amount,
      'category_id': transaction.categoryId,
      'date_time': transaction.dateTime.millisecondsSinceEpoch,
      'note': transaction.note,
      'payment_method': transaction.paymentMethod.id,
      'receipt_path': transaction.receiptPath,
      'updated_at': transaction.updatedAt ?? DateTime.now().millisecondsSinceEpoch,
      'sync_status': transaction.syncStatus ?? 'synced',
    }).match({'id': transaction.id, 'user_id': _userId}).execute();
  }
}
