import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiClient {
  ApiClient._();

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static void Function()? onSessionExpired;

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: 'auth_token');
            if (onSessionExpired != null) {
              onSessionExpired!();
            }
          }
          handler.next(error);
        },
      ),
    );

  static String mapError(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Tidak dapat terhubung ke server. Periksa koneksi lalu coba lagi.';
      }
      final status = error.response?.statusCode;
      if (status == 503 || status == 500) {
        return 'Terjadi gangguan pada server. Coba lagi sebentar lagi.';
      }
      if (status == 404) return 'Data tidak ditemukan.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
