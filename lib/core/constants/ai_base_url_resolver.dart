/// AI service đi cặp với backend deploy:
/// - Backend dev:  https://api-dev.mascoteach.com  → AI dev: https://ai-dev.mascoteach.com
/// - Backend prod: https://api.mascoteach.com      → AI prod: https://ai.mascoteach.com
///
/// Mặc định debug dùng AI dev DEPLOY (không phải localhost) — máy dev thường
/// không chạy AI service local, trỏ 10.0.2.2:5001 chỉ gây connection refused.
/// Ai muốn test AI local thì chạy với:
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

  if (isDebugMode) {
    return 'https://ai-dev.mascoteach.com';
  }

  return 'https://ai.mascoteach.com';
}
