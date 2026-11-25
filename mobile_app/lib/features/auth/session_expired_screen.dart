import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/widgets/confirm_dialog.dart';

class SessionExpiredScreen extends StatefulWidget {
  const SessionExpiredScreen({super.key});

  @override
  State<SessionExpiredScreen> createState() => _SessionExpiredScreenState();
}

class _SessionExpiredScreenState extends State<SessionExpiredScreen> {
  bool shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!shown) {
      shown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final confirmed = await ConfirmDialog.show(
          context,
          title: 'Sesi berakhir',
          content: 'Silakan masuk kembali.',
          actionLabel: 'Masuk',
        );
        if (confirmed && mounted) {
          await context.read<AuthProvider>().endSession();
          if (mounted) context.go('/login');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.expand());
}
