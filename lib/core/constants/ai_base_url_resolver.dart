/// AI service đi cặp với backend:
/// - Backend dev (mặc định): https://api-dev.mascoteach.com → AI dev: https://ai-dev.mascoteach.com
/// - Backend prod:           https://api.mascoteach.com     → AI prod: https://ai.mascoteach.com
///
/// Nhánh `dev` mặc định AI DEV (đi cặp api-dev). Lên prod thì override:
///   flutter build apk --release --dart-define=AI_BASE_URL=https://ai.mascoteach.com
///   flutter run --dart-define=AI_BASE_URL=http://10.0.2.2:5001
String resolveAiBaseUrl({
  required String overrideBaseUrl,
  required bool isDebugMode,
  required bool isWebRuntime,
}) {
  final normalizedOverride = overrideBaseUrl.trim();
  if (normalizedOverride.isNotEmpty) {
    return normalizedOverride;
  }

  return 'https://ai-dev.mascoteach.com';
}
