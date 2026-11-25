import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';

enum AuthStatus { unknown, unauthenticated, mustChangePassword, authenticated }

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage storage;
  AuthStatus status = AuthStatus.unknown;
  Map<String, dynamic>? user;

  AuthProvider({FlutterSecureStorage? storage})
      : storage = storage ?? const FlutterSecureStorage();

  Future<void> initialize() async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final response = await ApiClient.dio
          .get('/me', options: Options(headers: {'Authorization': 'Bearer $token'}))
          .timeout(const Duration(seconds: 5));
      user = Map<String, dynamic>.from(response.data['data']);
      status = user?['mustChangePassword'] == true
          ? AuthStatus.mustChangePassword
          : AuthStatus.authenticated;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await storage.delete(key: 'auth_token');
        status = AuthStatus.unauthenticated;
      } else {
        status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String identifier, String password) async {
    final response = await ApiClient.dio.post('/auth/login', data: {
      'identifier': identifier,
      'password': password,
    });
    final data = Map<String, dynamic>.from(response.data['data']);
    await storage.write(key: 'auth_token', value: data['token']);
    user = Map<String, dynamic>.from(data['user']);
    status = user?['mustChangePassword'] == true
        ? AuthStatus.mustChangePassword
        : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    final token = await storage.read(key: 'auth_token');
    await ApiClient.dio.post('/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    await storage.delete(key: 'auth_token');
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    final token = await storage.read(key: 'auth_token');
    if (token != null) {
      await ApiClient.dio.post('/auth/logout', options: Options(headers: {'Authorization': 'Bearer $token'}));
    }
    await storage.delete(key: 'auth_token');
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> endSession() async {
    await storage.delete(key: 'auth_token');
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> expireSession() async {
    await storage.delete(key: 'auth_token');
    status = AuthStatus.unauthenticated;
    user = null;
    notifyListeners();
  }
}
