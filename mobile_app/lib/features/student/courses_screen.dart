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

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});
  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final service = StudentService();
  bool loading = true;
  String? error;
  List<dynamic> semesters = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try { semesters = await service.getCourses(); } on DioException catch (e) { error = ApiClient.mapError(e); }
    finally { if (mounted) setState(() => loading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Courses')),
    body: loading
      ? ListView(padding: const EdgeInsets.all(16), children: const [SkeletonCard(), SizedBox(height: 12), SkeletonCard()])
      : error != null
        ? ErrorState(message: error!, onRetry: _load)
        : semesters.isEmpty
          ? const EmptyState(title: 'Belum ada mata kuliah yang diambil.', description: '')
          : ListView(padding: const EdgeInsets.all(16), children: [
              for (final semesterItem in semesters)
                Builder(builder: (_) {
                  final semester = Map<String, dynamic>.from(semesterItem);
                  final courses = List<dynamic>.from(semester['courses'] as List);
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Semester ${semester['semester']}', style: const TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(semester['academicTerm']?.toString() ?? '', style: const TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 12),
                    for (final courseItem in courses) ...[
                      Builder(builder: (_) {
                        final course = Map<String, dynamic>.from(courseItem);
                        return AppCard(onTap: () => context.push('/courses/${course['id']}'), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(course['code']?.toString() ?? '', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(course['name']?.toString() ?? '', style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('${course['credits']} SKS', style: const TextStyle(color: AppTheme.textSecondary)),
                        ]));
                      }),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 8),
                  ]);
                }),
            ]),
  );
}
