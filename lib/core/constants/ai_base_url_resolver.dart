String resolveAiBaseUrl({
  required String overrideBaseUrl,
  required bool isDebugMode,
  required bool isWebRuntime,
}) {
  final normalizedOverride = overrideBaseUrl.trim();
  if (normalizedOverride.isNotEmpty) {
    return normalizedOverride;
  }

  if (isDebugMode) {
    return isWebRuntime ? 'http://localhost:5001' : 'http://10.0.2.2:5001';
  }

  return 'https://ai.mascoteach.com';
}
