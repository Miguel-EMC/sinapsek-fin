import 'package:dio/dio.dart';
import 'api_client.dart';
import 'token_storage.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthService {
  static final _dio = ApiClient.instance;

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': email, 'password': password},
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );
      final token = response.data['access_token'] as String;
      await TokenStorage.save(token);
    } on DioException catch (e) {
      final msg = e.response?.data?['detail'] ?? 'Error al iniciar sesión';
      throw AuthException(msg.toString());
    }
  }

  static Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'full_name': fullName,
      });
    } on DioException catch (e) {
      final msg = e.response?.data?['detail'] ?? 'Error al registrarse';
      throw AuthException(msg.toString());
    }
  }

  static Future<void> logout() => TokenStorage.delete();

  static Future<bool> isLoggedIn() async {
    final token = await TokenStorage.read();
    return token != null;
  }
}
