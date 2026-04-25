import 'package:flutter/material.dart';
import 'package:qoucher/core/theme/app_theme.dart';
import 'package:qoucher/router/app_router.dart';
import 'package:qoucher/router/route_names.dart';

class QoucherApp extends StatelessWidget {
  const QoucherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Qoucher',
      theme: AppTheme.lightTheme,
      initialRoute: RouteNames.welcome,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}