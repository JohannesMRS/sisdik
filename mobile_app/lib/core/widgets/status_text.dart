import 'package:flutter/material.dart';

class StatusText extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const StatusText({super.key, required this.text, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 16, color: color),
    const SizedBox(width: 4),
    Text(text, style: TextStyle(fontSize: 12, color: color)),
  ]);
}
