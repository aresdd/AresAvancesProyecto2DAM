import 'package:flutter/material.dart';

import 'core/navigation/app_router.dart';
import 'core/navigation/app_routes.dart';
import 'theme/app_theme.dart';

/// Root widget of CalBalance.
class CalBalanceApp extends StatelessWidget {
  const CalBalanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalBalance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

