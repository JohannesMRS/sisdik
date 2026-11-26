import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/skeleton_box.dart';
import '../../services/student_service.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});
  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final service = StudentService();
  bool loading = true;
  String? error;
  Map<String, dynamic>? data;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try { data = await service.getCourseDetail(widget.courseId); } on DioException catch (e) { error = ApiClient.mapError(e); }
    finally { if (mounted) setState(() => loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (loading) {
      body = const Padding(padding: EdgeInsets.all(16), child: SkeletonCard());
    } else if (error != null) {
      body = ErrorState(message: error!, onRetry: _load);
    } else {
      final schedules = List<dynamic>.from(data!['schedules'] as List? ?? []);
      final assignments = List<dynamic>.from(data!['assignments'] as List? ?? []);
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(data!['code']?.toString() ?? '', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(data!['name']?.toString() ?? '', style: const TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text('Dosen: ${data!['lecturer']?.toString() ?? '-'}'),
          Text('${data!['credits']} SKS · Semester ${data!['semester']}'),
          const SizedBox(height: 20),
          const Text('Jadwal', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (schedules.isEmpty) const Text('Belum ada jadwal.'),
          for (final item in schedules)
            Builder(builder: (_) {
              final schedule = Map<String, dynamic>.from(item);
              return Padding(padding: const EdgeInsets.only(bottom: 8), child: AppCard(child: Text('Hari ${schedule['day_of_week']} · ${schedule['start_time']}–${schedule['end_time']} · ${schedule['room'] ?? '-'}')));
            }),
          const SizedBox(height: 12),
          const Text('Tugas', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (assignments.isEmpty) const Text('Belum ada tugas.'),
          for (final item in assignments)
            Builder(builder: (_) {
              final assignment = Map<String, dynamic>.from(item);
              final deadline = DateTime.tryParse(assignment['deadline']?.toString() ?? '')?.toLocal();
              return Padding(padding: const EdgeInsets.only(bottom: 8), child: AppCard(onTap: () => context.push('/assignments/${assignment['id']}'), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(assignment['title']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Deadline: ${deadline == null ? '-' : '${deadline.day}/${deadline.month}/${deadline.year}'}'),
                const SizedBox(height: 4),
                Text(assignment['status']?.toString() ?? '', style: const TextStyle(color: AppTheme.accent)),
              ])));
            }),
        ],
      );
    }

    return Scaffold(appBar: AppBar(title: Text(data?['name']?.toString() ?? 'Detail Mata Kuliah')), body: body);
  }
}
