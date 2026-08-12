import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/money_formatter.dart';
import '../../data/models/monthly_budget.dart';
import '../../data/repository/finance_repository.dart';
import '../../state/settings_notifier.dart';
import '../widgets/progress_bar.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late Future<MonthlyBudget> _budgetFuture;

  @override
  void initState() {
    super.initState();
    _budgetFuture = _loadBudget();
  }

  Future<MonthlyBudget> _loadBudget() async {
    final FinanceRepository repository = context.read<FinanceRepository>();
    final summary = await repository.fetchFinanceSummary();
    return summary.budget ?? MonthlyBudget.forMonth(summary.month, 0);
  }

  Future<void> _refresh() async {
    setState(() {
      _budgetFuture = _loadBudget();
    });
  }

  @override
  Widget build(BuildContext context) {
    final SettingsNotifier settings = context.watch<SettingsNotifier>();
    final MoneyFormatter formatter = MoneyFormatter(settings.currency);
    final FinanceRepository repository = context.read<FinanceRepository>();

    return FutureBuilder<MonthlyBudget>(
      future: _budgetFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final MonthlyBudget budget = snapshot.data ?? MonthlyBudget.forMonth(DateTime.now(), 0);

        return FutureBuilder(
          future: repository.fetchFinanceSummary(),
          builder: (context, summarySnapshot) {
            if (summarySnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final summary = summarySnapshot.data;
            if (summary == null) {
              return const Scaffold(
                body: Center(child: Text('Unable to load budget data.')),
              );
            }

            final double remaining = budget.amount - summary.monthExpense;
            final double usedRatio = budget.amount > 0
                ? (summary.monthExpense / budget.amount).clamp(0.0, 1.0)
                : 0.0;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Budget'),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _refresh,
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: <Widget>[
                    Text('Monthly Budget', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Budget', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              formatter.withMark(budget.amount),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 16),
                            Text('Spent', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 4),
                            Text(
                              formatter.withMark(summary.monthExpense),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            ProgressBar(
                              value: usedRatio,
                              label: 'Budget used',
                              foregroundColor: usedRatio >= 0.9
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              remaining >= 0
                                  ? '${formatter.withMark(remaining)} remaining'
                                  : '${formatter.withMark(remaining.abs())} over budget',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () async {
                        final double? amount = await _showBudgetInput(context, budget.amount);
                        if (amount != null) {
                          await repository.saveBudget(MonthlyBudget.forMonth(summary.month, amount));
                          await _refresh();
                        }
                      },
                      child: const Text('Set monthly budget'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<double?> _showBudgetInput(BuildContext context, double currentAmount) async {
    final TextEditingController controller = TextEditingController(text: currentAmount.toStringAsFixed(2));
    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Budget'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Monthly budget'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final double? parsed = double.tryParse(controller.text.trim());
                Navigator.pop(context, parsed);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
