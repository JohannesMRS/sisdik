import 'package:dio/dio.dart';
import '../config/app_config.dart';

class ApiClient {
  ApiClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
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
