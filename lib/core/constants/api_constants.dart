import 'package:flutter/foundation.dart';

import 'ai_base_url_resolver.dart';

/// Tập trung các hằng số API.
class ApiConstants {
  ApiConstants._();

  /// Base URL của Backend.
  ///
  /// Production (mặc định): https://api.mascoteach.com
  /// Dev:                   https://api-dev.mascoteach.com (swagger ở /swagger)
  ///
  /// Mặc định PROD để build release (CH Play) trỏ đúng server thật.
  /// Test dev thì override không cần sửa code:
  ///   flutter run --dart-define=API_BASE_URL=https://api-dev.mascoteach.com
  // LƯU Ý: phải dùng httpS — server (openresty) trả 301 redirect nếu gọi
  // http thường, và Dio không tự follow redirect cho POST → login nhận về
  // trang HTML 301 thay vì token.
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static String get baseUrl => _apiBaseUrlOverride.trim().isNotEmpty
      ? _apiBaseUrlOverride.trim()
      : 'https://api.mascoteach.com';
  static const String _aiBaseUrlOverride = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: '',
  );
  static String get aiBaseUrl => resolveAiBaseUrl(
    overrideBaseUrl: _aiBaseUrlOverride,
    isDebugMode: kDebugMode,
    isWebRuntime: kIsWeb,
  );
  static const String aiChat = '/api/v1/ai/chat';
  static const String mascotLiveHealth = '/api/v1/mascot-live/health';
  static const String mascotLiveSession = '/api/v1/mascot-live/session';
  static String mascotLiveSessionById(String sessionId) =>
      '/api/v1/mascot-live/session/$sessionId';
  static String mascotLiveEndSession(String sessionId) =>
      '/api/v1/mascot-live/session/$sessionId/end';

  // ============ Auth ============
  static const String authLogin = '/api/Auth/login';
  static const String authRegister = '/api/Auth/register';
  static const String authGoogleLogin = '/api/Auth/google-login';
  static const String authForgotPassword = '/api/Auth/forgot-password';
  static const String authResetPassword = '/api/Auth/reset-password';

  /// Web OAuth Client ID dùng cho Google Sign-In.
  ///
  /// Phải KHỚP với `Google:ClientId` trong `appsettings.json` của Backend
  /// (BE validate audience của idToken bằng Client ID này).
  ///
  /// Lấy ở Google Cloud Console → APIs & Services → Credentials → OAuth 2.0 Client IDs
  /// → loại "Web application". KHÔNG dùng Android client ID.
  ///
  /// Truyền lúc build qua --dart-define (không hardcode/commit):
  ///   --dart-define=GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com
  /// Phải KHỚP với `Google:ClientId` của backend (BE validate audience idToken).
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '121016526145-j2qd1503r84l9ior8gjdnkult9h8o9p2.apps.googleusercontent.com',
  );

  /// Bật/tắt nút "Đăng nhập với Google".
  ///
  /// ĐANG TẮT cho v1 vì cả mobile (`googleWebClientId`) lẫn backend
  /// (`Google:ClientId` trong appsettings) đều còn placeholder — bấm sẽ fail.
  /// Bật lại khi đã: (1) tạo OAuth Web Client ID trên Google Cloud,
  /// (2) điền KHỚP vào mobile + backend, (3) đăng ký SHA-1 keystore release.
  static final bool googleSignInEnabled =
      googleWebClientId != 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com';

  // ============ User ============
  static const String userMe = '/api/User/me';
  static const String users = '/api/User';

  // ============ Billing (PayOS) ============
  static const String billingCreatePaymentLink =
      '/api/Billing/create-payment-link';

  // ============ Quiz ============
  static const String quizzes = '/api/Quiz';

  // ============ Question ============
  static const String questions = '/api/Question';

  // ============ Option ============
  static const String options = '/api/Option';

  // ============ Document ============
  static const String documents = '/api/Document';
  static const String documentsMe = '/api/Document/me';
  static const String documentsPresign = '/api/Document/generate-upload-url';

  // ============ Game Template ============
  static const String gameTemplates = '/api/GameTemplate';

  // ============ Live Session ============
  static const String sessions = '/api/LiveSession';
  static const String sessionsMy = '/api/LiveSession/my';
  static String sessionByPin(String pin) => '/api/LiveSession/pin/$pin';

  // ============ Session Participant ============
  static const String participants = '/api/SessionParticipant';

  // ============ Gamification ============
  // Lưu ý: BE chỉ expose /me (không có /{userId}) và KHÔNG có endpoint
  // subscription upgrade — xem .codex/skills/mascoteach-gamification.md.
  static const String userStatsMe = '/api/UserStats/me';
  static const String quizAttempts = '/api/QuizAttempt';
  static const String quizAttemptsMe = '/api/QuizAttempt/me';

  // ============ Storage keys ============
  static const String tokenKey = 'mascoteach_token';
  static const String userKey = 'mascoteach_user';
}
