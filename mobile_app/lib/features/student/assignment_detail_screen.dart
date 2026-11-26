import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/skeleton_box.dart';
import '../../services/student_service.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final String assignmentId;
  const AssignmentDetailScreen({super.key, required this.assignmentId});
  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  final service = StudentService();
  bool loading = true;
  bool uploading = false;
  double progress = 0;
  String? error;
  Map<String, dynamic>? assignment;
  List<dynamic> history = [];
  PlatformFile? file;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      assignment = await service.getAssignmentDetail(widget.assignmentId);
      history = await service.getSubmissionHistory(widget.assignmentId);
    } on DioException catch (e) { error = ApiClient.mapError(e); }
    finally { if (mounted) setState(() => loading = false); }
  }

  Future<void> _pickFile() async {
    final picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['pdf', 'docx', 'zip']);
    if (picked == null) return;
    final size = picked.lengthSync() ?? await picked.length();
    if (size == null || size > 10 * 1024 * 1024) {
      setState(() => error = 'Ukuran file maksimal 10 MB.');
      return;
    }
    setState(() { file = picked; error = null; });
  }

  Future<void> _submit() async {
    if (file == null) return;
    final confirmed = await ConfirmDialog.show(context, title: 'Kirim tugas', content: 'Kirim file "${file!.name}"?', actionLabel: 'Kirim');
    if (!confirmed) return;
    setState(() { uploading = true; progress = 0; error = null; });
    try {
      await service.uploadSubmission(widget.assignmentId, file!, onProgress: (sent, total) {
        if (total > 0 && mounted) setState(() => progress = sent / total);
      });
      file = null;
      await _load();
    } on DioException catch (e) {
      error = ApiClient.mapError(e);
    } catch (_) {
      error = 'File tidak dapat dibaca.';
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detail Tugas')),
    body: loading
      ? const Padding(padding: EdgeInsets.all(16), child: SkeletonCard())
      : error != null && assignment == null
        ? ErrorState(message: error!, onRetry: _load)
        : ListView(padding: const EdgeInsets.all(16), children: [
            Text('${assignment!['courseCode']} · ${assignment!['courseName']}', style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text(assignment!['title']?.toString() ?? '', style: const TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(assignment!['description']?.toString() ?? ''),
            const SizedBox(height: 12),
            Text('Deadline: ${assignment!['deadline']}'),
            const SizedBox(height: 4),
            Text(assignment!['status']?.toString() ?? '', style: const TextStyle(color: AppTheme.accent)),
            const SizedBox(height: 20),
            const Text('Riwayat Pengumpulan', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (history.isEmpty) const Text('Belum ada file dikumpulkan.'),
            for (final item in history)
              AppCard(child: Builder(builder: (_) {
                final row = Map<String, dynamic>.from(item);
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(row['originalFilename']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${row['sizeBytes']} byte · ${row['submittedAt']}'),
                  if (row['isLatest'] == true) const Text('Versi terbaru', style: TextStyle(color: AppTheme.accent)),
                ]);
              })),
            const SizedBox(height: 16),
            if (error != null) Text(error!, style: const TextStyle(color: Color(0xFFDC2626))),
            if (uploading) LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: uploading ? null : _pickFile, child: const Text('Pilih File')),
            if (file != null) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('${file!.name} · ${file!.lengthSync() ?? 0} byte')),
            PrimaryButton(label: 'Kirim', loading: uploading, onPressed: file == null || uploading ? null : _submit),
          ]),
  );
}
