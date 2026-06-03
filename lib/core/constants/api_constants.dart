/// Tập trung các hằng số API.
class ApiConstants {
  ApiConstants._();

  /// Base URL của Backend.
  ///
  /// Production: https://api.mascoteach.com (đã deploy, swagger ở /swagger)
  ///
  /// Nếu muốn test với backend chạy local, đổi sang một trong các URL sau:
  /// - Android emulator:  'https://10.0.2.2:7108'   (10.0.2.2 = host machine)
  /// - Web (Chrome):      'https://localhost:7108'
  /// - Thiết bị thật:     'https://192.168.x.x:7108' (IP LAN máy host)
  static const String baseUrl = 'https://api.mascoteach.com';
  static const String aiBaseUrl = 'https://ai.mascoteach.com:8443';

  // ============ Auth ============
  static const String authLogin = '/api/Auth/login';
  static const String authRegister = '/api/Auth/register';

  // ============ User ============
  static const String userMe = '/api/User/me';
  static const String users = '/api/User';

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

  // ============ Storage keys ============
  static const String tokenKey = 'mascoteach_token';
  static const String userKey = 'mascoteach_user';
}
