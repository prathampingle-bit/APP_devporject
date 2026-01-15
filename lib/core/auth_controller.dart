import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_api.dart';
import 'models.dart';
import 'secure_storage_service.dart';

class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.token, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null && token != null;
  String? get role => user?.role;

  AuthState copyWith(
      {User? user, String? token, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  factory AuthState.initial() => const AuthState();
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({required this.api}) : super(AuthState.initial());

  final AuthApi api;
  final _storage = SecureStorageService.instance;

  Future<void> loadSession() async {
    final token = await _storage.readToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await api.me(token);
      state = AuthState(user: user, token: token, isLoading: false);
    } catch (_) {
      await _storage.clearToken();
      state = AuthState.initial();
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await api.login(email: email, password: password);
      await _storage.writeToken(res.token);
      state = AuthState(user: res.user, token: res.token, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Invalid credentials');
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearToken();
    state = AuthState.initial();
  }
}
