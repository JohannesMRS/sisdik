import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  const EmptyState({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textSecondary),
    const SizedBox(height: 12),
    Text(title, style: const TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w600)),
    const SizedBox(height: 4),
    Text(description, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
  ])));
}
