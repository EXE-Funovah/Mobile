import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/api/auth_api.dart';
import '../../../data/models/user.dart';
import '../../../data/storage/token_storage.dart';

class AuthState {
  final bool loading;
  final String? token;
  final UserRole role;
  final String? displayName;
  final String? error;

  const AuthState({
    this.loading = false,
    this.token,
    this.role = UserRole.unknown,
    this.displayName,
    this.error,
  });

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthState copyWith({
    bool? loading,
    String? token,
    UserRole? role,
    String? displayName,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      token: token ?? this.token,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState()) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final token = await TokenStorage.instance.getToken();
    final name = await TokenStorage.instance.getDisplayName();
    final roleStr = await TokenStorage.instance.getRole();

    if (token != null && token.isNotEmpty) {
      state = state.copyWith(
        token: token,
        displayName: name,
        role: roleStr != null ? roleFromString(roleStr) : UserRole.unknown,
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final res = await AuthApi.instance.login(
        email: email,
        password: password,
      );
      await TokenStorage.instance.setToken(res.token);
      if (res.fullName != null) {
        await TokenStorage.instance.setDisplayName(res.fullName!);
      }
      if (res.role != null) {
        await TokenStorage.instance.setRole(res.role!);
      }
      state = AuthState(
        token: res.token,
        role: roleFromString(res.role),
        displayName: res.fullName,
      );
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: _msg(e));
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await AuthApi.instance.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );
      // Sau khi đăng ký, tự login luôn
      return await login(email, password);
    } catch (e) {
      state = state.copyWith(loading: false, error: _msg(e));
      return false;
    }
  }

  /// Đăng nhập bằng Google. Trả về true nếu thành công, false nếu user hủy hoặc lỗi.
  Future<bool> googleSignIn() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      // serverClientId = Web Client ID của BE; cần thiết để idToken có audience đúng.
      final google = GoogleSignIn(
        scopes: const ['email', 'profile', 'openid'],
        serverClientId: ApiConstants.googleWebClientId,
      );

      // Sign out trước để luôn hiện account picker thay vì auto chọn account cũ
      await google.signOut();
      final account = await google.signIn();
      if (account == null) {
        // user cancel
        state = state.copyWith(loading: false);
        return false;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Không lấy được Google idToken. Kiểm tra cấu hình OAuth Android.',
        );
      }

      final res = await AuthApi.instance.googleLogin(idToken: idToken);
      await TokenStorage.instance.setToken(res.token);
      if (res.fullName != null) {
        await TokenStorage.instance.setDisplayName(res.fullName!);
      }
      if (res.role != null) {
        await TokenStorage.instance.setRole(res.role!);
      }
      state = AuthState(
        token: res.token,
        role: roleFromString(res.role),
        displayName: res.fullName,
      );
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: _msg(e));
      return false;
    }
  }

  Future<void> logout() async {
    // Sign out khỏi Google luôn để lần sau user có thể chọn account khác
    try {
      await GoogleSignIn(serverClientId: ApiConstants.googleWebClientId)
          .signOut();
    } catch (_) {
      // Bỏ qua lỗi nếu Google chưa init
    }
    await TokenStorage.instance.clear();
    state = const AuthState();
  }

  String _msg(Object e) {
    final s = e.toString();
    return s.replaceFirst('Exception: ', '');
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);
