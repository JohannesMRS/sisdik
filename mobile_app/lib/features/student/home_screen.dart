import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/skeleton_box.dart';
import '../../services/student_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = StudentService();
  bool loading = true;
  String? error;
  List<dynamic> assignments = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      assignments = await service.getHomeAssignments();
    } on DioException catch (exception) {
      error = ApiClient.mapError(exception);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Home')),
    body: RefreshIndicator(onRefresh: _load, child: loading
      ? ListView(padding: const EdgeInsets.all(16), children: const [SkeletonCard(), SizedBox(height: 12), SkeletonCard()])
      : error != null
        ? ListView(children: [SizedBox(height: MediaQuery.sizeOf(context).height * 0.55, child: ErrorState(message: error!, onRetry: _load))])
        : assignments.isEmpty
          ? const EmptyState(title: 'Tidak ada tugas untuk saat ini.', description: 'Belum ada tugas yang perlu ditinjau.')
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: assignments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = Map<String, dynamic>.from(assignments[index]);
                final deadline = DateTime.tryParse(item['deadline']?.toString() ?? '')?.toLocal();
                return AppCard(
                  onTap: () => context.push('/assignments/${item['id']}'),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${item['courseCode']} · ${item['courseName']}', style: const TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 6),
                    Text(item['title']?.toString() ?? '', style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(item['description']?.toString() ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text('Deadline: ${deadline == null ? '-' : '${deadline.day}/${deadline.month}/${deadline.year} ${deadline.hour}:${deadline.minute.toString().padLeft(2, '0')}'}'),
                    const SizedBox(height: 4),
                    Text(item['status']?.toString() ?? '', style: const TextStyle(color: AppTheme.accent)),
                  ]),
                );
              },
            ),
    ),
  );
}
