import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/money_formatter.dart';
import '../../../data/models/transaction_kind.dart';
import '../../../data/models/payment_method.dart';
import '../../../data/models/money_transaction.dart';
import '../../../data/models/tx_category.dart';
import '../../../data/repository/finance_repository.dart';
import '../../presentation/widgets/transaction_list_view.dart';
import '../../presentation/widgets/transaction_tile.dart';
import '../../state/settings_notifier.dart';
import '../../state/transaction_notifier.dart';
import 'transaction_form_screen.dart';
import 'transaction_details_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({
    super.key,
    required this.kind,
  });

  final TransactionKind kind;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TransactionListNotifier>(
      create: (context) {
        final notifier = TransactionListNotifier(
          Provider.of<FinanceRepository>(context, listen: false),
          kind: kind,
        );
        notifier.load();
        return notifier;
      },
      child: Consumer<TransactionListNotifier>(
        builder: (context, notifier, child) {
          final settings = Provider.of(context, listen: false);
          final formatter = MoneyFormatter(settings.currency);
          return Scaffold(
            appBar: AppBar(
              title: Text(kind == TransactionKind.expense ? 'Expenses' : 'Income'),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: notifier.load,
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_outlined),
                      hintText: 'Search transactions',
                    ),
                    onChanged: notifier.setSearchQuery,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: notifier.categoryId,
                          decoration: const InputDecoration(
                            labelText: 'Category filter',
                          ),
                          items: <DropdownMenuItem<String?>>[
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All categories'),
                            ),
                            ...notifier.categoryOptions.map(
                              (TxCategory category) => DropdownMenuItem<String>(
                                value: category.id,
                                child: Text(category.label),
                              ),
                            ),
                          ],
                          onChanged: notifier.setCategoryId,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: notifier.paymentMethodId,
                          decoration: const InputDecoration(labelText: 'Payment method'),
                          items: <DropdownMenuItem<String?>>[
                            const DropdownMenuItem<String?>(value: null, child: Text('Any')),
                            ...PaymentMethod.values.map((m) => DropdownMenuItem<String>(value: m.id, child: Text(m.label))).toList(),
                          ],
                          onChanged: notifier.setPaymentMethodId,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'Min amount'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: notifier.setMinAmount,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'Max amount'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: notifier.setMaxAmount,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (notifier.isLoading)
                    const Expanded(child: Center(child: CircularProgressIndicator()))
                  else if (notifier.errorMessage != null)
                    Expanded(
                      child: Center(
                        child: Text('Error loading transactions: ${notifier.errorMessage}'),
                      ),
                    )
                  else if (notifier.filteredTransactions.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'No ${kind.label.toLowerCase()} transactions found.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: TransactionListView(
                        transactions: notifier.filteredTransactions,
                        onTap: (MoneyTransaction transaction) async {
                          final Object? result = await Navigator.push<Object?>(
                            context,
                            MaterialPageRoute<Object?>(
                              builder: (context) => TransactionDetailsScreen(
                                transaction: transaction,
                              ),
                            ),
                          );
                          if (result is MoneyTransaction) {
                            await notifier.updateTransaction(result);
                          } else if (result == 'deleted') {
                            await notifier.deleteTransaction(transaction.id);
                          }
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    'Total ${kind.label}: ${formatter.withMark(notifier.totalAmount)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                final MoneyTransaction? result = await Navigator.push<MoneyTransaction?>(
                  context,
                  MaterialPageRoute<MoneyTransaction?>(
                    builder: (context) => TransactionFormScreen(kind: kind),
                  ),
                );
                if (result != null) {
                  await notifier.addTransaction(result);
                }
              },
              icon: const Icon(Icons.add),
              label: Text('Add ${kind.label.toLowerCase()}'),
            ),
          );
        },
      ),
    );
  }
}
