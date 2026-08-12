import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../../core/utils/app_dates.dart';
import '../models/money_transaction.dart';
import '../models/monthly_budget.dart';
import '../models/recurring_transaction.dart';
import '../datasources/transaction_data_source.dart';
import 'seed_data.dart';

class SqliteTransactionDataSource implements TransactionDataSource {
  SqliteTransactionDataSource._(this._db);

  final Database _db;

  static Future<SqliteTransactionDataSource> initialize({bool seed = true}) async {
    final String databasesPath = await getDatabasesPath();
    final String dbPath = path.join(databasesPath, 'hisabpro.db');
    final Database database = await openDatabase(
      dbPath,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    if (seed) {
      final int count = Sqflite.firstIntValue(
            await database.rawQuery('SELECT COUNT(*) FROM transactions'),
          ) ??
          0;
      if (count == 0) {
        await _seed(database);
      }
    }

    return SqliteTransactionDataSource._(database);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        kind TEXT NOT NULL,
        amount REAL NOT NULL,
        category_id TEXT NOT NULL,
        date_time INTEGER NOT NULL,
        note TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        receipt_path TEXT
        ,user_id TEXT
        ,updated_at INTEGER
        ,sync_status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets(
        id TEXT PRIMARY KEY,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        amount REAL NOT NULL,
        user_id TEXT,
        updated_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE recurrings(
        id TEXT PRIMARY KEY,
        kind TEXT NOT NULL,
        amount REAL NOT NULL,
        category_id TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        frequency TEXT NOT NULL,
        note TEXT NOT NULL,
        payment_method TEXT,
        active INTEGER NOT NULL,
        user_id TEXT,
        next_occurrence INTEGER,
        updated_at INTEGER
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new sync-related columns safely; ignore errors if they already exist.
      try {
        await db.execute('ALTER TABLE transactions ADD COLUMN user_id TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE transactions ADD COLUMN updated_at INTEGER');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE transactions ADD COLUMN sync_status TEXT');
      } catch (_) {}

      try {
        await db.execute('ALTER TABLE budgets ADD COLUMN user_id TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE budgets ADD COLUMN updated_at INTEGER');
      } catch (_) {}

      // Create new recurrings table if it doesn't exist and attempt to migrate old data.
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS recurrings(
            id TEXT PRIMARY KEY,
            kind TEXT NOT NULL,
            amount REAL NOT NULL,
            category_id TEXT NOT NULL,
            start_date INTEGER NOT NULL,
            frequency TEXT NOT NULL,
            note TEXT NOT NULL,
            payment_method TEXT,
            active INTEGER NOT NULL,
            user_id TEXT,
            next_occurrence INTEGER,
            updated_at INTEGER
          )
        ''');
      } catch (_) {}

      // Attempt to move records from legacy `recurring` table to `recurrings` if present.
      try {
        final List<Map<String, Object?>> rows = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='recurring'");
        if (rows.isNotEmpty) {
          final List<Map<String, Object?>> old = await db.query('recurring');
          final Batch batch = db.batch();
          for (final row in old) {
            batch.insert('recurrings', row as Map<String, Object?>, conflictAlgorithm: ConflictAlgorithm.replace);
          }
          await batch.commit(noResult: true);
          try {
            await db.execute('DROP TABLE IF EXISTS recurring');
          } catch (_) {}
        }
      } catch (_) {}
    }
  }

  static Future<void> _seed(Database db) async {
    final DateTime now = DateTime.now();
    final DateTime thisMonth = AppDates.startOfMonth(now);
    final DateTime lastMonth = DateTime(now.year, now.month - 1);

    final List<MoneyTransaction> seededTransactions = <MoneyTransaction>[];
    seededTransactions.addAll(
      SeedData.buildForMonth(
        thisMonth,
        SeedData.currentMonth,
        notAfter: now,
      ),
    );
    seededTransactions.addAll(
      SeedData.buildForMonth(
        lastMonth,
        SeedData.lastMonth,
      ),
    );
    seededTransactions.addAll(
      SeedData.buildForMonth(
        AppDates.startOfDay(now),
        SeedData.today,
        notAfter: now,
        forceDayToMonthDay: true,
      ),
    );

    final Batch batch = db.batch();

    for (final MoneyTransaction transaction in seededTransactions) {
      batch.insert(
        'transactions',
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final List<MonthlyBudget> budgets = SeedData.defaultBudgets(now);
    for (final MonthlyBudget budget in budgets) {
      batch.insert(
        'budgets',
        budget.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<List<MoneyTransaction>> fetchTransactions() async {
    final List<Map<String, Object?>> rows = await _db.query(
      'transactions',
      orderBy: 'date_time DESC, id DESC',
    );
    return rows.map((Map<String, Object?> row) => MoneyTransaction.fromMap(row)).toList();
  }

  @override
  Future<void> addTransaction(MoneyTransaction transaction) async {
    await _db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateTransaction(MoneyTransaction transaction) async {
    await _db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: <Object?>[transaction.id],
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  @override
  Future<List<MonthlyBudget>> fetchBudgets() async {
    final List<Map<String, Object?>> rows = await _db.query(
      'budgets',
      orderBy: 'year DESC, month DESC',
    );
    return rows.map((Map<String, Object?> row) => MonthlyBudget.fromMap(row)).toList();
  }

  @override
  Future<void> saveBudget(MonthlyBudget budget) async {
    await _db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ---------------------------------------------------------------- recurring

  @override
  Future<List<RecurringTransaction>> fetchRecurringTransactions() async {
    final List<Map<String, Object?>> rows = await _db.query(
      'recurrings',
      orderBy: 'start_date DESC, id DESC',
    );
    return rows.map((Map<String, Object?> row) => RecurringTransaction.fromMap(row)).toList();
  }

  @override
  Future<void> addRecurringTransaction(RecurringTransaction transaction) async {
    await _db.insert(
      'recurrings',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateRecurringTransaction(RecurringTransaction transaction) async {
    await _db.update(
      'recurrings',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: <Object?>[transaction.id],
    );
  }

  @override
  Future<void> deleteRecurringTransaction(String id) async {
    await _db.delete(
      'recurrings',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }
}
