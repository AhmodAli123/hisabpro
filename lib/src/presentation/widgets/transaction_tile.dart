import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../core/constants/app_currencies.dart';
import '../../../core/utils/app_dates.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../data/models/money_transaction.dart';
import '../../state/settings_notifier.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final MoneyTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MoneyFormatter formatter = MoneyFormatter(
      Provider.of<SettingsNotifier>(context, listen: true).currency,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
          child: Icon(transaction.category.icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(transaction.displayTitle),
        subtitle: Text(AppDates.dayMedium(transaction.dateTime)),
        trailing: Text(
          formatter.withMark(transaction.amount),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: transaction.isExpense
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
