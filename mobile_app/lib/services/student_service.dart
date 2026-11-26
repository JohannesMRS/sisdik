import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../core/api_client.dart';

class StudentService {
  Future<List<dynamic>> getHomeAssignments() async {
    final response = await ApiClient.dio.get('/student/home/assignments');
    return List<dynamic>.from(response.data['data'] as List);
  }

  Future<List<dynamic>> getCourses() async {
    final response = await ApiClient.dio.get('/student/courses');
    return List<dynamic>.from(response.data['data'] as List);
  }

  Future<Map<String, dynamic>> getCourseDetail(String courseId) async {
    final response = await ApiClient.dio.get('/student/courses/$courseId');
    return Map<String, dynamic>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> getAssignmentDetail(String assignmentId) async {
    final response = await ApiClient.dio.get('/student/assignments/$assignmentId');
    return Map<String, dynamic>.from(response.data['data']);
  }

  Future<List<dynamic>> getSubmissionHistory(String assignmentId) async {
    final response = await ApiClient.dio.get('/student/assignments/$assignmentId/submissions');
    return List<dynamic>.from(response.data['data'] as List);
  }

  Future<void> uploadSubmission(String assignmentId, PlatformFile file, {required void Function(int, int) onProgress}) async {
    final bytes = await file.readAsBytes();

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: file.name),
    });
    await ApiClient.dio.post(
      '/student/assignments/$assignmentId/submissions',
      data: formData,
      onSendProgress: onProgress,
    );
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiClient.dio.get('/me');
    return Map<String, dynamic>.from(response.data['data']);
  }

  Future<List<dynamic>> getPasswordHistories() async {
    final response = await ApiClient.dio.get('/me/password-histories');
    return List<dynamic>.from(response.data['data'] as List);
  }
}
