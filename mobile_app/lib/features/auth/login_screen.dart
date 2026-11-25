import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool obscurePassword = true;
  String? errorText;

  Future<void> login() async {
    if (identifierController.text.trim().isEmpty || passwordController.text.isEmpty) {
      setState(() => errorText = 'NIM/NIP dan password wajib diisi.');
      return;
    }
    setState(() { loading = true; errorText = null; });
    try {
      await context.read<AuthProvider>().login(identifierController.text.trim(), passwordController.text);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        setState(() => errorText = 'NIM/NIP atau password salah.');
      } else {
        setState(() => errorText = ApiClient.mapError(error));
      }
    } catch (_) {
      setState(() => errorText = 'Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 72),
      const Text('SISDIK', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
      const SizedBox(height: 8),
      const Text('Sistem Informasi Akademik', textAlign: TextAlign.center),
      const SizedBox(height: 32),
      AppTextField(label: 'NIM / NIP', controller: identifierController, errorText: null),
      const SizedBox(height: 16),
      AppTextField(label: 'Password', controller: passwordController, obscureText: obscurePassword, suffixIcon: IconButton(icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => obscurePassword = !obscurePassword))),
      if (errorText != null) ...[
        const SizedBox(height: 12),
        Text(errorText!, style: const TextStyle(color: Color(0xFFDC2626))),
      ],
      const SizedBox(height: 24),
      PrimaryButton(label: 'Masuk', loading: loading, onPressed: login),
      const SizedBox(height: 8),
      TextButton(onPressed: () => context.push('/forgot-password'), child: const Text('Lupa password?')),
    ]))),
  );
}
