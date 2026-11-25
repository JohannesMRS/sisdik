import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  // Emulator Android: 10.0.2.2 | iOS simulator: localhost
  // HP fisik: pakai IP laptop, misal 192.168.1.10
  static const String baseUrl = 'http://127.0.0.1:3000/api/v1';

  Future<List<User>> getUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/users'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => User.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat data');
  }
}