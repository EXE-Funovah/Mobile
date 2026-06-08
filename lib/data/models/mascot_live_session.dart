class MascotLiveSession {
  const MascotLiveSession({
    required this.provider,
    required this.engine,
    required this.sessionId,
    required this.status,
    required this.displayName,
    required this.language,
    required this.voice,
    required this.model,
    required this.clientSecret,
    required this.connection,
    required this.notes,
  });

  final String provider;
  final String engine;
  final String sessionId;
  final String status;
  final String displayName;
  final String language;
  final String voice;
  final String model;
  final OpenAiRealtimeClientSecret clientSecret;
  final MascotLiveConnectionInfo connection;
  final List<String> notes;

  factory MascotLiveSession.fromJson(Map<String, dynamic> json) {
    final rawNotes = json['notes'];
    return MascotLiveSession(
      provider: _stringOf(json['provider'], fallback: 'openai'),
      engine: _stringOf(json['engine'], fallback: 'openai_realtime_webrtc'),
      sessionId: _stringOf(json['sessionId']),
      status: _stringOf(json['status'], fallback: 'created'),
      displayName: _stringOf(json['displayName'], fallback: 'Mascot learner'),
      language: _stringOf(json['language'], fallback: 'vi'),
      voice: _stringOf(json['voice'], fallback: 'marin'),
      model: _stringOf(json['model'], fallback: 'gpt-realtime-2'),
      clientSecret: OpenAiRealtimeClientSecret.fromJson(
        _mapOf(json['clientSecret']),
      ),
      connection: MascotLiveConnectionInfo.fromJson(_mapOf(json['connection'])),
      notes: rawNotes is List
          ? rawNotes
                .map((item) => _stringOf(item))
                .where((e) => e.isNotEmpty)
                .toList()
          : const [],
    );
  }
}

class OpenAiRealtimeClientSecret {
  const OpenAiRealtimeClientSecret({
    required this.value,
    required this.expiresAt,
  });

  final String value;
  final String? expiresAt;

  factory OpenAiRealtimeClientSecret.fromJson(Map<String, dynamic> json) {
    return OpenAiRealtimeClientSecret(
      value: _stringOf(
        json['value'] ??
            (json['client_secret'] is Map
                ? (json['client_secret'] as Map)['value']
                : null),
      ),
      expiresAt: _nullableStringOf(
        json['expiresAt'] ??
            json['expires_at'] ??
            (json['client_secret'] is Map
                ? (json['client_secret'] as Map)['expires_at']
                : null),
      ),
    );
  }
}

class MascotLiveConnectionInfo {
  const MascotLiveConnectionInfo({
    required this.apiBaseUrl,
    required this.callEndpoint,
    required this.dataChannelLabel,
    required this.transport,
  });

  final String apiBaseUrl;
  final String callEndpoint;
  final String dataChannelLabel;
  final String transport;

  factory MascotLiveConnectionInfo.fromJson(Map<String, dynamic> json) {
    return MascotLiveConnectionInfo(
      apiBaseUrl: _stringOf(
        json['apiBaseUrl'],
        fallback: 'https://api.openai.com',
      ),
      callEndpoint: _stringOf(
        json['callEndpoint'],
        fallback: '/v1/realtime/calls',
      ),
      dataChannelLabel: _stringOf(
        json['dataChannelLabel'],
        fallback: 'oai-events',
      ),
      transport: _stringOf(json['transport'], fallback: 'webrtc'),
    );
  }
}

Map<String, dynamic> _mapOf(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return const {};
}

String _stringOf(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString();
  return text.isEmpty ? fallback : text;
}

String? _nullableStringOf(Object? value) {
  final text = _stringOf(value);
  return text.isEmpty ? null : text;
}
