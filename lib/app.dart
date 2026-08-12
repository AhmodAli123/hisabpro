import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_info.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/sqlite_transaction_data_source.dart';
import 'data/repository/finance_repository.dart';
import 'src/presentation/shell/app_shell.dart';
import 'src/state/settings_notifier.dart';

class HisabProApp extends StatefulWidget {
  const HisabProApp({super.key});

  @override
  State<HisabProApp> createState() => _HisabProAppState();
}

class _HisabProAppState extends State<HisabProApp> {
  late final Future<_AppStartupState> _startupFuture;

  @override
  void initState() {
    super.initState();
    _startupFuture = _initializeApp();
  }

  Future<_AppStartupState> _initializeApp() async {
    final SettingsNotifier settings = await SettingsNotifier.create();
    final SqliteTransactionDataSource dataSource =
        await SqliteTransactionDataSource.initialize(seed: true);
    final AuthNotifier auth = await AuthNotifier.create();
    return _AppStartupState(
      settings: settings,
      repository: FinanceRepository(dataSource),
      auth: auth,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppStartupState>(
      future: _startupFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final _AppStartupState startup = snapshot.data!;

        return MultiProvider(
          providers: <Provider<Object>>[
            Provider<FinanceRepository>.value(value: startup.repository),
            ChangeNotifierProvider<SettingsNotifier>.value(value: startup.settings),
            ChangeNotifierProvider<AuthNotifier>.value(value: startup.auth),
          ],
          child: Consumer<SettingsNotifier>(
            builder: (context, settings, child) {
              return MaterialApp(
                title: AppInfo.name,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: settings.themeMode,
                home: const AppShell(),
              );
            },
          ),
        );
      },
    );
  }
}

class _AppStartupState {
  _AppStartupState({
    required this.settings,
    required this.repository,
    required this.auth,
  });

  final SettingsNotifier settings;
  final FinanceRepository repository;
  final AuthNotifier auth;
}
