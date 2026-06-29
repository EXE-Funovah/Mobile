import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/jwt_utils.dart';
import '../../../data/api/auth_api.dart';
import '../../../data/api/dio_client.dart';
import '../../../data/models/user.dart';
import '../../../data/storage/token_storage.dart';

/// Giống thông báo web hiển thị khi token bị 401 (api.js).
const sessionExpiredMessage =
    'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';

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
  AuthController({
    bool bootstrapOnInit = true,
    Future<AuthResult> Function({
      required String email,
      required String password,
    })?
    loginRequest,
    Future<void> Function({
      required String fullName,
      required String email,
      required String password,
      required String role,
    })?
    registerRequest,
    Future<AuthResult> Function({required String idToken})? googleLoginRequest,
    Future<void> Function({required String email})? resendVerificationRequest,
    Future<String?> Function()? tokenReader,
    Future<String?> Function()? displayNameReader,
    Future<String?> Function()? roleReader,
    Future<void> Function(String token)? tokenWriter,
    Future<void> Function(String name)? displayNameWriter,
    Future<void> Function(String role)? roleWriter,
    Future<void> Function()? clearStorage,
  }) : _loginRequest = loginRequest ?? AuthApi.instance.login,
       _registerRequest = registerRequest ?? AuthApi.instance.register,
       _googleLoginRequest = googleLoginRequest ?? AuthApi.instance.googleLogin,
       _resendVerificationRequest =
           resendVerificationRequest ?? AuthApi.instance.resendVerification,
       _tokenReader = tokenReader ?? TokenStorage.instance.getToken,
       _displayNameReader =
           displayNameReader ?? TokenStorage.instance.getDisplayName,
       _roleReader = roleReader ?? TokenStorage.instance.getRole,
       _tokenWriter = tokenWriter ?? TokenStorage.instance.setToken,
       _displayNameWriter =
           displayNameWriter ?? TokenStorage.instance.setDisplayName,
       _roleWriter = roleWriter ?? TokenStorage.instance.setRole,
       _clearStorage = clearStorage ?? TokenStorage.instance.clear,
       super(const AuthState()) {
    // DioClient báo về khi token bị 401/hết hạn → force logout để router
    // đá về /login (web làm tương tự: clearAuth → redirect /signin).
    DioClient.onSessionExpired = sessionExpired;
    if (bootstrapOnInit) {
      _bootstrap();
    }
  }

  final Future<AuthResult> Function({
    required String email,
    required String password,
  })
  _loginRequest;
  final Future<void> Function({
    required String fullName,
    required String email,
    required String password,
    required String role,
  })
  _registerRequest;
  final Future<AuthResult> Function({required String idToken})
  _googleLoginRequest;
  final Future<void> Function({required String email})
  _resendVerificationRequest;
  final Future<String?> Function() _tokenReader;
  final Future<String?> Function() _displayNameReader;
  final Future<String?> Function() _roleReader;
  final Future<void> Function(String token) _tokenWriter;
  final Future<void> Function(String name) _displayNameWriter;
  final Future<void> Function(String role) _roleWriter;
  final Future<void> Function() _clearStorage;

  Future<void> _bootstrap() async {
    final token = await _tokenReader();
    final name = await _displayNameReader();
    final roleStr = await _roleReader();

    if (token != null && token.isNotEmpty) {
      // JWT backend sống 60' và không có refresh endpoint — token cũ trong
      // storage gần như chắc chắn đã chết khi mở lại app. Khôi phục nó chỉ
      // tạo phiên "ma": UI tưởng đăng nhập nhưng mọi API đều 401.
      if (isJwtExpired(token)) {
        await _clearStorage();
        return;
      }
      state = state.copyWith(
        token: token,
        displayName: name,
        role: roleStr != null ? roleFromString(roleStr) : UserRole.unknown,
      );
    }
  }

  /// Token bị backend từ chối (401) hoặc hết hạn giữa phiên.
  void sessionExpired() {
    if (!mounted || !state.isAuthenticated) return;
    state = const AuthState(error: sessionExpiredMessage);
  }

  /// Xoá error sau khi đã hiển thị (vd. snackbar ở LoginPage).
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final res = await _loginRequest(email: email, password: password);
      await _applyAuthResult(res);
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
      await _registerRequest(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );
      state = state.copyWith(loading: false, clearError: true);
      return true;
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

      final res = await _googleLoginRequest(idToken: idToken);
      await _applyAuthResult(res);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: _msg(e));
      return false;
    }
  }

  Future<bool> resendVerification(String email) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _resendVerificationRequest(email: email);
      state = state.copyWith(loading: false, clearError: true);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: _msg(e));
      return false;
    }
  }

  Future<void> logout() async {
    // Sign out khỏi Google luôn để lần sau user có thể chọn account khác
    try {
      await GoogleSignIn(
        serverClientId: ApiConstants.googleWebClientId,
      ).signOut();
    } catch (_) {
      // Bỏ qua lỗi nếu Google chưa init
    }
    await _clearStorage();
    state = const AuthState();
  }

  Future<void> _applyAuthResult(AuthResult res) async {
    await _tokenWriter(res.token);
    if (res.fullName != null) {
      await _displayNameWriter(res.fullName!);
    }
    if (res.role != null) {
      await _roleWriter(res.role!);
    }
    state = AuthState(
      token: res.token,
      role: roleFromString(res.role),
      displayName: res.fullName,
    );
  }

  String _msg(Object e) {
    final s = e.toString();
    return s.replaceFirst('Exception: ', '');
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);
