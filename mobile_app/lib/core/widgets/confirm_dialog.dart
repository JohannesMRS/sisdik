import 'package:flutter/material.dart';

class ConfirmDialog {
  static Future<bool> show(BuildContext context, {required String title, required String content, required String actionLabel, bool destructive = false}) async {
    final result = await showDialog<bool>(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text(actionLabel, style: TextStyle(color: destructive ? const Color(0xFFDC2626) : null))),
      ],
    ));
    return result ?? false;
  }
}
