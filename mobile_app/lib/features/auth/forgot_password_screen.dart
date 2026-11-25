import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final identifierController = TextEditingController();
  bool loading = false;
  bool success = false;
  String? errorText;

  Future<void> submit() async {
    if (identifierController.text.trim().isEmpty) {
      setState(() => errorText = 'NIM/NIP wajib diisi.');
      return;
    }
    setState(() { loading = true; errorText = null; });
    try {
      await ApiClient.dio.post('/auth/forgot-password', data: {'identifier': identifierController.text.trim()});
      setState(() => success = true);
    } on DioException catch (error) {
      setState(() => errorText = ApiClient.mapError(error));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Lupa Password')), body: Padding(padding: const EdgeInsets.all(16), child: success
      ? Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.check_circle_outline, size: 64, color: Color(0xFF15803D)),
          const SizedBox(height: 12),
          const Text('Jika NIM/NIP terdaftar, permintaan reset sudah dicatat. Hubungi pengelola untuk menerima password sementara.', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Kembali ke Login', onPressed: () => context.go('/login')),
        ])
      : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Masukkan NIM/NIP. Permintaan akan diteruskan, lalu kamu akan menerima password sementara.'),
          const SizedBox(height: 24),
          AppTextField(label: 'NIM / NIP', controller: identifierController, errorText: errorText),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Kirim Permintaan', loading: loading, onPressed: submit),
        ])));
}
