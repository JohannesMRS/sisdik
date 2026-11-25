import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  bool loading = false;
  bool showCurrent = false;
  bool showNew = false;
  bool showConfirm = false;
  String? errorText;

  bool get minLength => newController.text.length >= 8;
  bool get hasLetterAndNumber => RegExp(r'[A-Za-z]').hasMatch(newController.text) && RegExp(r'[0-9]').hasMatch(newController.text);
  bool get maxLength => newController.text.length <= 72;
  bool get differsFromCurrent => newController.text.isNotEmpty && newController.text != currentController.text;

  Future<void> submit() async {
    if (!minLength || !hasLetterAndNumber || !maxLength || !differsFromCurrent) {
      setState(() => errorText = 'Password baru belum memenuhi semua aturan.');
      return;
    }
    if (newController.text != confirmController.text) {
      setState(() => errorText = 'Konfirmasi password tidak sama.');
      return;
    }
    setState(() { loading = true; errorText = null; });
    try {
      await context.read<AuthProvider>().changePassword(currentController.text, newController.text, confirmController.text);
    } on DioException catch (error) {
      setState(() => errorText = ApiClient.mapError(error));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Ganti Password'), automaticallyImplyLeading: false), body: Padding(padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const Text('Demi keamanan, ganti password awal sebelum melanjutkan.'),
    const SizedBox(height: 24),
    AppTextField(label: 'Password lama', controller: currentController, obscureText: !showCurrent, onChanged: (_) => setState(() {}), suffixIcon: IconButton(icon: Icon(showCurrent ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => showCurrent = !showCurrent))),
    const SizedBox(height: 16),
    AppTextField(label: 'Password baru', controller: newController, obscureText: !showNew, onChanged: (_) => setState(() {}), suffixIcon: IconButton(icon: Icon(showNew ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => showNew = !showNew))),
    const SizedBox(height: 16),
    AppTextField(label: 'Konfirmasi password baru', controller: confirmController, obscureText: !showConfirm, onChanged: (_) => setState(() {}), suffixIcon: IconButton(icon: Icon(showConfirm ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => showConfirm = !showConfirm))),
    const SizedBox(height: 16),
    Text('Min 8 karakter', style: TextStyle(color: minLength ? const Color(0xFF15803D) : null)),
    Text('Huruf dan angka', style: TextStyle(color: hasLetterAndNumber ? const Color(0xFF15803D) : null)),
    Text('Tidak sama dengan password lama', style: TextStyle(color: differsFromCurrent ? const Color(0xFF15803D) : null)),
    Text('Maksimal 72 karakter', style: TextStyle(color: maxLength ? const Color(0xFF15803D) : null)),
    if (errorText != null) ...[const SizedBox(height: 12), Text(errorText!, style: const TextStyle(color: Color(0xFFDC2626)))],
    const SizedBox(height: 24),
    PrimaryButton(label: 'Simpan Password', loading: loading, onPressed: submit),
  ]))));
}
