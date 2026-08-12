import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_info.dart';
import '../../../core/utils/app_dates.dart';
import '../../../core/utils/money_formatter.dart';
import '../../presentation/widgets/dashboard_card.dart';
import '../../presentation/widgets/segment_panel.dart';
import '../../state/settings_notifier.dart';
import '../../../data/repository/finance_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsNotifier settings = context.watch<SettingsNotifier>();
    final currencyFormatter = MoneyFormatter(settings.currency);
    final FinanceRepository repository = context.read<FinanceRepository>();

    return FutureBuilder(
      future: repository.fetchFinanceSummary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = snapshot.data;
        if (summary == null) {
          return const Center(child: Text('Unable to load dashboard.'));
        }

        return SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                title: Text(AppInfo.name),
                centerTitle: false,
                elevation: 0,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      Text(
                        AppDates.monthYear(summary.month),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      DashboardCard(
                        title: 'Total Balance',
                        value: currencyFormatter.signed(summary.totalBalance, includeMark: true),
                        subtitle: 'Across all records',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DashboardCard(
                              title: 'Monthly Income',
                              value: currencyFormatter.withMark(summary.monthIncome),
                              subtitle: 'This month',
                              indicatorColor: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DashboardCard(
                              title: 'Monthly Expense',
                              value: currencyFormatter.withMark(summary.monthExpense),
                              subtitle: 'This month',
                              indicatorColor: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DashboardCard(
                        title: 'Remaining Budget',
                        value: currencyFormatter.withMark(summary.budgetRemaining),
                        subtitle: summary.hasBudget ? 'Budget left for this month' : 'No budget set',
                        indicatorColor: summary.budgetRemaining >= 0
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      SegmentPanel(
                        title: 'Today\'s Expense',
                        value: currencyFormatter.withMark(summary.todayExpense),
                        icon: const Icon(Icons.today_outlined),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      const Center(child: Text('Transaction list will appear in Phase 2.')),
                      const SizedBox(height: 16),
                      Text(
                        'Expense Categories',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...summary.categoryBreakdown
                          .map(
                            (category) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(category.category.icon),
                              title: Text(category.category.label),
                              trailing:
                                  Text(currencyFormatter.withMark(category.total)),
                              subtitle: Text('${category.count} transactions • ${currencyFormatter.percent(category.total, summary.monthExpense)}'),
                            ),
                          )
                          .toList(),
                      const SizedBox(height: 24),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.remove_circle_outline),
                              label: const Text('Add Expense'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Add Income'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
