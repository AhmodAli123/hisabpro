import 'package:flutter/foundation.dart';

import '../../data/datasources/cloud_transaction_data_source.dart';
import '../../data/datasources/sqlite_transaction_data_source.dart';
import '../../data/models/money_transaction.dart';
import 'supabase_storage_service.dart';

/// Simple sync service that performs a basic two-way sync between the local
/// SQLite data source and Supabase cloud data source.
class SyncService {
  SyncService._(this._local, this._cloud);

  final SqliteTransactionDataSource _local;
  final CloudTransactionDataSource _cloud;

  static Future<SyncService> create({SqliteTransactionDataSource? local, CloudTransactionDataSource? cloud}) async {
    final SqliteTransactionDataSource localDs = local ?? await SqliteTransactionDataSource.initialize(seed: false);
    final CloudTransactionDataSource cloudDs = cloud ?? await CloudTransactionDataSource.create();
    return SyncService._(localDs, cloudDs);
  }

  /// Perform a quick sync: push local pending items, then pull remote and
  /// merge into local DB. This is intentionally simple; conflict handling is
  /// last-writer-wins based on `updatedAt` and will mark conflicts for later
  /// review.
  Future<void> syncAll() async {
    // Push pending local transactions
    final List<MoneyTransaction> local = await _local.fetchTransactions();
    final List<MoneyTransaction> pending = local.where((t) => (t.syncStatus ?? '') != 'synced').toList();
    for (final t in pending) {
      try {
        // If there is a local receipt path, try uploading it to Supabase Storage
        if ((t.receiptPath ?? '').isNotEmpty && !(t.receiptPath!.startsWith('http')) ) {
          final String? url = await SupabaseStorageService.instance.uploadReceipt(t.receiptPath!);
          if (url != null) {
            final MoneyTransaction withUrl = t.copyWith(receiptPath: url, syncStatus: 'pending', updatedAt: DateTime.now().millisecondsSinceEpoch);
            await _cloud.addTransaction(withUrl);
            final MoneyTransaction updated = withUrl.copyWith(
              syncStatus: 'synced',
              updatedAt: DateTime.now().millisecondsSinceEpoch,
            );
            await _local.updateTransaction(updated);
            continue;
          }
        }
        await _cloud.addTransaction(t);
        final MoneyTransaction updated = t.copyWith(
          syncStatus: 'synced',
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        await _local.updateTransaction(updated);
      } catch (e) {
        debugPrint('Failed to push transaction ${t.id}: $e');
      }
    }

    // Pull remote transactions and merge
    final List<MoneyTransaction> remote = await _cloud.fetchTransactions();
    final Map<String, MoneyTransaction> localMap = {for (final e in local) e.id: e};

    for (final r in remote) {
      final localExisting = localMap[r.id];
      if (localExisting == null) {
        // Insert remote record locally as synced
        final MoneyTransaction toInsert = MoneyTransaction(
          id: r.id,
          kind: r.kind,
          amount: r.amount,
          categoryId: r.categoryId,
          dateTime: r.dateTime,
          note: r.note,
          paymentMethod: r.paymentMethod,
          receiptPath: r.receiptPath,
          userId: r.userId,
          updatedAt: r.updatedAt,
          syncStatus: 'synced',
        );
        await _local.addTransaction(toInsert);
      } else {
        final int remoteUpdated = r.updatedAt ?? 0;
        final int localUpdated = localExisting.updatedAt ?? 0;
        if (remoteUpdated > localUpdated) {
          // Remote wins
          final MoneyTransaction toUpdate = MoneyTransaction(
            id: r.id,
            kind: r.kind,
            amount: r.amount,
            categoryId: r.categoryId,
            dateTime: r.dateTime,
            note: r.note,
            paymentMethod: r.paymentMethod,
            receiptPath: r.receiptPath,
            userId: r.userId,
            updatedAt: r.updatedAt,
            syncStatus: 'synced',
          );
          await _local.updateTransaction(toUpdate);
        } else if (localUpdated > remoteUpdated) {
          // Local is newer: push it
          try {
            await _cloud.addTransaction(localExisting);
            final MoneyTransaction updated = localExisting.copyWith(syncStatus: 'synced', updatedAt: DateTime.now().millisecondsSinceEpoch);
            await _local.updateTransaction(updated);
          } catch (e) {
            debugPrint('Failed to push newer local ${localExisting.id}: $e');
          }
        } else {
          // same timestamp — nothing to do
        }
      }
    }
  }
}
