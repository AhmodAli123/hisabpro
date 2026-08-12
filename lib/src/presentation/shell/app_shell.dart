import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/transaction_kind.dart';
import '../../state/settings_notifier.dart';
import '../screens/budget_screen.dart';
import '../screens/home_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/transaction_list_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    const TransactionListScreen(kind: TransactionKind.expense),
    const TransactionListScreen(kind: TransactionKind.income),
    const ReportsScreen(),
    const BudgetScreen(),
    const SettingsScreen(),
  ];

  static final List<NavigationDestination> _destinations = <NavigationDestination>[
    const NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
    const NavigationDestination(icon: Icon(Icons.trending_down_outlined), label: 'Expenses'),
    const NavigationDestination(icon: Icon(Icons.trending_up_outlined), label: 'Income'),
    const NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Reports'),
    const NavigationDestination(icon: Icon(Icons.wallet_outlined), label: 'Budget'),
    const NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 640) {
            return Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: theme.colorScheme.surface,
                  destinations: _destinations
                      .map(
                        (NavigationDestination destination) => NavigationRailDestination(
                          icon: destination.icon,
                          selectedIcon: destination.icon,
                          label: Text(destination.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _pages[_selectedIndex]),
              ],
            );
          }

          return Scaffold(
            body: _pages[_selectedIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: _destinations,
            ),
          );
        },
      ),
    );
  }
}
