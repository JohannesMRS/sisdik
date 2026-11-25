import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/primary_button.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  String? result;
  String? error;
  bool loading = false;

  Future<void> loadHealth() async {
    setState(() { loading = true; error = null; result = null; });
    try {
      final response = await ApiClient.dio.get('/health');
      setState(() => result = 'Status: ${response.data['data']['status']} · DB: ${response.data['data']['db']}');
    } on DioException catch (exception) {
      setState(() => error = ApiClient.mapError(exception));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SISDIK')),
    body: Padding(padding: const EdgeInsets.all(16), child: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
            ? ErrorState(message: error!, onRetry: loadHealth)
            : Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (result != null) Text(result!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                PrimaryButton(label: 'Periksa Koneksi', onPressed: loadHealth),
              ])),
  );
}
