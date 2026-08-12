import 'package:flutter/material.dart';

import '../../../data/models/money_transaction.dart';
import '../../presentation/widgets/transaction_tile.dart';

class TransactionListView extends StatelessWidget {
  const TransactionListView({
    super.key,
    required this.transactions,
    required this.onTap,
  });

  final List<MoneyTransaction> transactions;
  final void Function(MoneyTransaction) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (BuildContext context, int index) {
        final MoneyTransaction transaction = transactions[index];
        return TransactionTile(
          transaction: transaction,
          onTap: () => onTap(transaction),
        );
      },
    );
  }
}
