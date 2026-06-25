/// AI service đi cặp với backend:
/// - Backend prod (mặc định): https://api.mascoteach.com     → AI prod: https://ai.mascoteach.com
/// - Backend dev:             https://api-dev.mascoteach.com → AI dev: https://ai-dev.mascoteach.com
///
/// Mặc định AI PROD (đi cặp với api prod mặc định) cho build release.
/// Test dev / local thì override không cần sửa code:
///   flutter run --dart-define=AI_BASE_URL=https://ai-dev.mascoteach.com
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

  return 'https://ai.mascoteach.com';
}
