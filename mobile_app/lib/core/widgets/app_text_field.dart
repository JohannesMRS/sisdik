import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const AppTextField({super.key, required this.label, this.controller, this.errorText, this.obscureText = false, this.suffixIcon, this.keyboardType});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextField(controller: controller, obscureText: obscureText, keyboardType: keyboardType, decoration: InputDecoration(errorText: errorText, suffixIcon: suffixIcon)),
    ],
  );
}
