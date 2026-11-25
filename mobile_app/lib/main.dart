import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/health/health_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SISDIK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: const HealthScreen(),
    );
  }
}