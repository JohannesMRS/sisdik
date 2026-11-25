import 'package:flutter/material.dart';

class AppBottomSheet {
  static Future<T?> show<T>(BuildContext context, {required String title, required Widget child}) {
    return showModalBottomSheet<T>(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (context) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))),
      Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w600))),
      child,
    ])));
  }
}
