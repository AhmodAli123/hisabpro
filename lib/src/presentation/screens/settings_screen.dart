import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/settings_notifier.dart';
import '../../../core/constants/app_currencies.dart';
import '../../state/transaction_notifier.dart';
import '../../../core/services/storage_service.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../data/repository/finance_repository.dart';
import '../../state/auth_notifier.dart';
import 'auth_screen.dart';
import '../../../data/datasources/cloud_transaction_data_source.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsNotifier settings = context.watch<SettingsNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Currency'),
            subtitle: Text(settings.currency.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: const Text('Select Currency'),
                    children: AppCurrencies.all
                        .map(
                          (currency) => SimpleDialogOption(
                            onPressed: () {
                              settings.setCurrency(currency);
                              Navigator.pop(context);
                            },
                            child: Text('${currency.mark} ${currency.name}'),
                          ),
                        )
                        .toList(),
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(settings.themeMode.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: const Text('Select Theme'),
                    children: <Widget>[
                      SimpleDialogOption(
                        onPressed: () {
                          settings.setThemeMode(ThemeMode.light);
                          Navigator.pop(context);
                        },
                        child: const Text('Light'),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          settings.setThemeMode(ThemeMode.dark);
                          Navigator.pop(context);
                        },
                        child: const Text('Dark'),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          settings.setThemeMode(ThemeMode.system);
                          Navigator.pop(context);
                        },
                        child: const Text('System'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const Divider(height: 32),
          const ListTile(
            title: Text('About'),
            subtitle: Text('HisabPro is a personal finance manager for budget tracking.'),
          ),
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text(AppInfo.version),
          ),
          const Divider(height: 24),
          Text('Data', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              final repository = Provider.of<FinanceRepository>(context, listen: false);
              final transactions = await repository.fetchTransactions();
              final budgets = await repository._dataSource.fetchBudgets();
              final recurrings = await repository.fetchRecurringTransactions();
              final path = await StorageService.instance.writeJsonBackup(
                transactions: transactions,
                budgets: budgets,
                recurrings: recurrings,
                filename: 'hisabpro-backup-${DateTime.now().toIso8601String()}.json',
              );
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup saved: $path')));
            },
            child: const Text('Backup (JSON)'),
          ),
          const SizedBox(height: 12),
          Consumer<AuthNotifier>(
            builder: (context, auth, child) {
              if (auth.isAuthenticated) {
                return FilledButton(
                  onPressed: () async {
                    await auth.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out')));
                  },
                  child: const Text('Sign out'),
                );
              }
              return FilledButton(
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
                },
                child: const Text('Sign in / Register'),
              );
            },
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              final repository = Provider.of<FinanceRepository>(context, listen: false);
              final transactions = await repository.fetchTransactions();
              final path = await StorageService.instance.writeCsvTransactions(transactions, 'hisabpro-transactions-${DateTime.now().toIso8601String()}.csv');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV exported: $path')));
            },
            child: const Text('Export Transactions (CSV)'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles();
              if (result == null) return;
              final File file = File(result.files.single.path!);
              final Map<String, dynamic> dump = await StorageService.instance.readJsonBackup(file);
              // Basic restore: currently only logs; full import requires careful merging.
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup loaded: ${file.path}')));
            },
            child: const Text('Restore Backup (JSON)'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final AuthNotifier auth = Provider.of(context, listen: false);
              if (!auth.isAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in first to sync to cloud')));
                return;
              }
              final repository = Provider.of<FinanceRepository>(context, listen: false);
              final cloud = await CloudTransactionDataSource.create();
              final transactions = await repository.fetchTransactions();
              int pushed = 0;
              for (final t in transactions) {
                try {
                  await cloud.addTransaction(t);
                  pushed += 1;
                } catch (_) {
                  // ignore individual failures for now
                }
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Synced $pushed transactions to cloud')));
            },
            child: const Text('Sync to Cloud (one-way)'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final AuthNotifier auth = Provider.of(context, listen: false);
              if (!auth.isAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in first to sync')));
                return;
              }
              final SyncService sync = await SyncService.create();
              await sync.syncAll();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Full sync complete')));
            },
            child: const Text('Run Full Sync (two-way)'),
          ),
        ],
      ),
    );
  }
}
