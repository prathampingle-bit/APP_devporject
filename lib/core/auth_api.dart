import 'package:dio/dio.dart';
import 'models.dart';

class AuthApi {
  AuthApi({Dio? client}) : _client = client ?? Dio();

  final Dio _client;
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000/api',
  );

  Future<AuthResponse> login(
      {required String email, required String password}) async {
    final res = await _client.post('$_baseUrl/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = res.data as Map<String, dynamic>;
    return AuthResponse(
      token: data['token'] as String,
      user: User.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<User> me(String token) async {
    final res = await _client.get(
      '$_baseUrl/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final data = res.data as Map<String, dynamic>;
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});
}

final authApi = AuthApi();
