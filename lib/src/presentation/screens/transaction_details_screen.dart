import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_dates.dart';
import 'dart:io';
import '../../../core/utils/money_formatter.dart';
import '../../../core/constants/app_currencies.dart';
import '../../../data/models/money_transaction.dart';
import '../../../data/models/payment_method.dart';
import '../../../data/models/transaction_kind.dart';
import '../../state/settings_notifier.dart';
import '../screens/transaction_form_screen.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  final MoneyTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final Currency currency = context.watch<SettingsNotifier>().currency;
    final MoneyFormatter formatter = MoneyFormatter(currency);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final MoneyTransaction? updated = await Navigator.push<MoneyTransaction?>(
                context,
                MaterialPageRoute<MoneyTransaction?>(
                  builder: (context) => TransactionFormScreen(
                    kind: transaction.kind,
                    transaction: transaction,
                  ),
                ),
              );
              if (updated != null) {
                Navigator.pop(context, updated);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final bool confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete transaction'),
                      content: const Text('Are you sure you want to delete this transaction?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ) ??
                  false;
              if (confirmed) {
                Navigator.pop(context, 'deleted');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: const Text('Amount'),
              subtitle: Text(formatter.withMark(transaction.amount)),
            ),
            ListTile(
              title: const Text('Type'),
              subtitle: Text(transaction.kind.label),
            ),
            ListTile(
              title: const Text('Category'),
              subtitle: Text(transaction.category.label),
              leading: Icon(transaction.category.icon),
            ),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(AppDates.dayFull(transaction.dateTime)),
            ),
            ListTile(
              title: const Text('Time'),
              subtitle: Text(AppDates.time(transaction.dateTime)),
            ),
            ListTile(
              title: const Text('Payment Method'),
              subtitle: Text(transaction.paymentMethod.label),
              leading: Icon(transaction.paymentMethod.icon),
            ),
            if (transaction.hasNote) ...[
              const Divider(),
              ListTile(
                title: const Text('Note'),
                subtitle: Text(transaction.note),
              ),
            ],
            if (transaction.hasReceipt) ...[
              const Divider(),
              ListTile(
                title: const Text('Receipt'),
                subtitle: transaction.receiptPath != null ? Image.file(File(transaction.receiptPath!)) : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
