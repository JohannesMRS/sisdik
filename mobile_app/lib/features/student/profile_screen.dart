import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/skeleton_box.dart';
import '../../providers/auth_provider.dart';
import '../../services/student_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final service = StudentService();
  bool loading = true;
  String? error;
  Map<String, dynamic>? profile;
  List<dynamic> histories = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try { profile = await service.getProfile(); histories = await service.getPasswordHistories(); }
    on DioException catch (e) { error = ApiClient.mapError(e); }
    finally { if (mounted) setState(() => loading = false); }
  }

  Future<void> _logout() async {
    final confirmed = await ConfirmDialog.show(context, title: 'Keluar', content: 'Apakah Anda yakin ingin keluar?', actionLabel: 'Keluar', destructive: true);
    if (confirmed && mounted) await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: loading
      ? const Padding(padding: EdgeInsets.all(16), child: SkeletonCard())
      : error != null
        ? ErrorState(message: error!, onRetry: _load)
        : profile == null
          ? const EmptyState(title: 'Profil tidak tersedia.', description: '')
          : ListView(padding: const EdgeInsets.all(16), children: [
              Text(profile!['name']?.toString() ?? '', style: const TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('NIM: ${profile!['nim'] ?? profile!['identifier']}'),
              Text('IPK: ${double.tryParse(profile!['gpa']?.toString() ?? '')?.toStringAsFixed(2) ?? '0.00'}'),
              const SizedBox(height: 20),
              const Text('Riwayat Perubahan Password', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (histories.isEmpty) const Text('Belum ada riwayat perubahan password.'),
              for (final item in histories)
                Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('${item['changedAt']} · ${item['type']}')),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () => context.push('/change-password'), child: const Text('Ganti Password')),
              const SizedBox(height: 12),
              const Text('Biometric', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
              const Text('Belum dikonfigurasi'),
              const SizedBox(height: 20),
              OutlinedButton(onPressed: _logout, child: const Text('Keluar')),
            ]),
  );
}
