import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../state/settings_notifier.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../data/repository/finance_repository.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FinanceRepository repository = context.read<FinanceRepository>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.date_range_outlined),
            onPressed: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                initialDateRange: _selectedRange,
              );
              if (picked != null) {
                setState(() => _selectedRange = picked);
              }
            },
          ),
          if (_selectedRange != null)
            IconButton(
              icon: const Icon(Icons.clear_outlined),
              onPressed: () => setState(() => _selectedRange = null),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Tab>[
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'Yearly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _DailyReport(repository: repository, range: _selectedRange),
          _WeeklyReport(repository: repository, range: _selectedRange),
          _MonthlyReport(repository: repository, range: _selectedRange),
          _YearlyReport(repository: repository, range: _selectedRange),
        ],
      ),
    );
  }
}

class _DailyReport extends StatelessWidget {
  const _DailyReport({required this.repository, this.range});

  final FinanceRepository repository;
  final DateTimeRange? range;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();
    final formatter = MoneyFormatter(settings.currency);

    return FutureBuilder(
      future: repository.fetchTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final List transactions = snapshot.data as List? ?? <Object>[];
        final DateTime today = DateTime.now();
        final List todayTx = transactions.where((tx) {
          final DateTime dt = (tx as dynamic).dateTime as DateTime;
          if (range != null) return !dt.isBefore(range!.start) && !dt.isAfter(range!.end);
          return dt.year == today.year && dt.month == today.month && dt.day == today.day;
        }).toList();

        final double totalIncome = todayTx.fold(0.0, (double running, tx) => running + (((tx as dynamic).isIncome ? (tx as dynamic).amount : 0.0) as double));
        final double totalExpense = todayTx.fold(0.0, (double running, tx) => running + (((tx as dynamic).isExpense ? (tx as dynamic).amount : 0.0) as double));

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              Text('Today', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Total Income', style: Theme.of(context).textTheme.bodyMedium),
                      Text(formatter.withMark(totalIncome), style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text('Total Expense', style: Theme.of(context).textTheme.bodyMedium),
                      Text(formatter.withMark(totalExpense), style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Transactions', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...todayTx.map((tx) {
                return ListTile(
                  leading: Icon((tx as dynamic).category.icon),
                  title: Text((tx as dynamic).displayTitle),
                  subtitle: Text('${(tx as dynamic).paymentMethod.label}'),
                  trailing: Text(
                    formatter.withMark((tx as dynamic).amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: (tx as dynamic).isExpense ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

class _WeeklyReport extends StatelessWidget {
  const _WeeklyReport({required this.repository, this.range});

  final FinanceRepository repository;
  final DateTimeRange? range;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();
    final formatter = MoneyFormatter(settings.currency);
    return FutureBuilder(
      future: repository.fetchTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        final List txs = snapshot.data as List? ?? <Object>[];
        final DateTime now = DateTime.now();
        final DateTime weekStart = range != null ? range!.start : now.subtract(Duration(days: now.weekday - 1));
        final Map<int, double> byDay = <int, double>{};
        for (int i = 0; i < 7; i++) byDay[i] = 0.0;
        for (final tx in txs) {
          final DateTime d = (tx as dynamic).dateTime as DateTime;
          if (range != null) {
            if (d.isBefore(range!.start) || d.isAfter(range!.end)) continue;
          } else {
            if (d.isBefore(weekStart)) continue;
          }
          final int index = range != null ? d.difference(range!.start).inDays.clamp(0, 6) : d.difference(weekStart).inDays.clamp(0, 6);
          byDay[index] = byDay[index]! + ((tx as dynamic).isExpense ? (tx as dynamic).amount as double : 0.0);
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Last 7 days', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                        final int idx = v.toInt();
                        final DateTime labelDate = DateTime.now().subtract(Duration(days: 6 - idx));
                        return Text('${labelDate.month}/${labelDate.day}', style: Theme.of(context).textTheme.bodySmall);
                      })),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: byDay.entries.map((e) {
                      return BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value, color: Theme.of(context).colorScheme.error)]);
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Total spent: ${formatter.withMark(byDay.values.fold(0.0, (a, b) => a + b))}', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        );
      },
    );
  }
}

class _MonthlyReport extends StatelessWidget {
  const _MonthlyReport({required this.repository, this.range});

  final FinanceRepository repository;
  final DateTimeRange? range;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();
    final formatter = MoneyFormatter(settings.currency);
    return FutureBuilder(
      future: range == null ? repository.fetchReportData() : repository.fetchTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data;
        if (data == null) return const Center(child: Text('No data'));

        // If a custom range is selected, compute aggregates locally from transactions
        final dynamic reportData;
        if (range == null) {
          reportData = data;
        } else {
          final List txs = data as List;
          final List filtered = txs.where((tx) {
            final DateTime d = (tx as dynamic).dateTime as DateTime;
            return !d.isBefore(range!.start) && !d.isAfter(range!.end);
          }).toList();

          final double totalIncome = filtered.fold(0.0, (double r, tx) => r + (((tx as dynamic).isIncome ? (tx as dynamic).amount : 0.0) as double));
          final double totalExpense = filtered.fold(0.0, (double r, tx) => r + (((tx as dynamic).isExpense ? (tx as dynamic).amount : 0.0) as double));
          final double net = totalIncome - totalExpense;
          final categoryMap = <dynamic, Map<String, dynamic>>{};
          for (final tx in filtered) {
            final cat = (tx as dynamic).category;
            final key = cat.id;
            final double prev = categoryMap[key]?['total'] ?? 0.0;
            final int count = categoryMap[key]?['count'] ?? 0;
            categoryMap[key] = {'category': cat, 'total': prev + ((tx as dynamic).isExpense ? (tx as dynamic).amount as double : 0.0), 'count': count + 1};
          }
          final categoryBreakdown = categoryMap.values.map((m) => {
                'category': m['category'],
                'total': m['total'],
                'count': m['count'],
                'share': totalExpense == 0 ? 0.0 : (m['total'] as double) / totalExpense,
              }).toList();

          reportData = {
            'totalIncome': totalIncome,
            'totalExpense': totalExpense,
            'netBalance': net,
            'categoryBreakdown': categoryBreakdown,
            'monthlyComparison': <dynamic>[],
          };
        }

        // Pie chart sections for category breakdown
        final sections = <PieChartSectionData>[];
        final categoryList = (reportData is Map) ? reportData['categoryBreakdown'] as List : (reportData as dynamic).categoryBreakdown as List;
        for (final c in categoryList) {
          final total = reportData is Map ? c['total'] as double : (c as dynamic).total as double;
          final share = reportData is Map ? c['share'] as double : (c as dynamic).share as double;
          sections.add(PieChartSectionData(
            value: total,
            title: '${(share * 100).toStringAsFixed(0)}%',
            color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              Text('This Month', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Total Income', style: Theme.of(context).textTheme.bodyMedium),
                      Text(formatter.withMark(reportData is Map ? reportData['totalIncome'] as double : (reportData as dynamic).totalIncome), style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Total Expense', style: Theme.of(context).textTheme.bodyMedium),
                      Text(formatter.withMark(reportData is Map ? reportData['totalExpense'] as double : (reportData as dynamic).totalExpense), style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Net', style: Theme.of(context).textTheme.bodyMedium),
                      Text(formatter.withMark(reportData is Map ? reportData['netBalance'] as double : (reportData as dynamic).netBalance), style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Category breakdown', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...(categoryList).map((c) {
                final cat = reportData is Map ? c['category'] : (c as dynamic).category;
                final total = reportData is Map ? c['total'] : (c as dynamic).total;
                final share = reportData is Map ? c['share'] : (c as dynamic).share;
                final count = reportData is Map ? c['count'] : (c as dynamic).count;
                return ListTile(
                  leading: Icon((cat as dynamic).icon),
                  title: Text((cat as dynamic).label),
                  trailing: Text(formatter.withMark(total as double)),
                  subtitle: Text('${(share * 100).toStringAsFixed(1)}% • ${count} transactions'),
                );
              }).toList(),
              const SizedBox(height: 16),
              Text('Monthly comparison', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: ((reportData is Map ? (reportData['monthlyComparison'] as List) : (reportData as dynamic).monthlyComparison) as List)
                        .asMap()
                        .entries
                        .map((e) => BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(toY: (e.value as dynamic).expense as double, color: Theme.of(context).colorScheme.error),
                                BarChartRodData(toY: (e.value as dynamic).income as double, color: Theme.of(context).colorScheme.secondary),
                              ],
                            ))
                        .toList(),
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

class _YearlyReport extends StatelessWidget {
  const _YearlyReport({required this.repository, this.range});

  final FinanceRepository repository;
  final DateTimeRange? range;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();
    final formatter = MoneyFormatter(settings.currency);
    return FutureBuilder(
      future: repository.fetchTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        final List txs = snapshot.data as List? ?? <Object>[];
        final DateTime now = DateTime.now();
        final int year = now.year;
        final Map<int, double> incomeByMonth = {for (int m = 1; m <= 12; m++) m: 0.0};
        final Map<int, double> expenseByMonth = {for (int m = 1; m <= 12; m++) m: 0.0};
        for (final tx in txs) {
          final DateTime d = (tx as dynamic).dateTime as DateTime;
          if (d.year != year) continue;
          if ((tx as dynamic).isIncome) {
            incomeByMonth[d.month] = incomeByMonth[d.month]! + (tx as dynamic).amount as double;
          } else {
            expenseByMonth[d.month] = expenseByMonth[d.month]! + (tx as dynamic).amount as double;
          }
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Year $year', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(12, (index) {
                      final int month = index + 1;
                      return BarChartGroupData(x: index, barRods: [
                        BarChartRodData(toY: expenseByMonth[month]!, color: Theme.of(context).colorScheme.error),
                        BarChartRodData(toY: incomeByMonth[month]!, color: Theme.of(context).colorScheme.secondary),
                      ]);
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Year totals', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Income: ${formatter.withMark(incomeByMonth.values.fold(0.0, (a, b) => a + b))}'),
              Text('Expense: ${formatter.withMark(expenseByMonth.values.fold(0.0, (a, b) => a + b))}'),
            ],
          ),
        );
      },
    );
  }
}
