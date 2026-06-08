class MascotLiveSession {
  const MascotLiveSession({
    required this.sessionId,
    required this.status,
    required this.displayName,
    required this.language,
    required this.voice,
    required this.rtc,
    required this.agent,
  });

  final String sessionId;
  final String status;
  final String displayName;
  final String language;
  final String voice;
  final AgoraRtcConnectionInfo rtc;
  final AgoraAgentSessionInfo agent;

  factory MascotLiveSession.fromJson(Map<String, dynamic> json) {
    return MascotLiveSession(
      sessionId: _stringOf(json['sessionId']),
      status: _stringOf(json['status'], fallback: 'created'),
      displayName: _stringOf(json['displayName'], fallback: 'Mascot learner'),
      language: _stringOf(json['language'], fallback: 'vi'),
      voice: _stringOf(json['voice']),
      rtc: AgoraRtcConnectionInfo.fromJson(_mapOf(json['rtc'])),
      agent: AgoraAgentSessionInfo.fromJson(_mapOf(json['agent'])),
    );
  }
}

class AgoraRtcConnectionInfo {
  const AgoraRtcConnectionInfo({
    required this.appId,
    required this.channelName,
    required this.uid,
    required this.token,
    required this.tokenExpiresAt,
  });

  final String appId;
  final String channelName;
  final int uid;
  final String? token;
  final String? tokenExpiresAt;

  factory AgoraRtcConnectionInfo.fromJson(Map<String, dynamic> json) {
    return AgoraRtcConnectionInfo(
      appId: _stringOf(json['appId']),
      channelName: _stringOf(json['channelName']),
      uid: _intOf(json['uid']),
      token: _nullableStringOf(json['token']),
      tokenExpiresAt: _nullableStringOf(json['tokenExpiresAt']),
    );
  }
}

class AgoraAgentSessionInfo {
  const AgoraAgentSessionInfo({
    required this.agentRtcUid,
    required this.remoteRtcUids,
    required this.agentId,
    required this.status,
    required this.lastError,
    required this.notes,
  });

  final String agentRtcUid;
  final List<String> remoteRtcUids;
  final String? agentId;
  final String status;
  final String? lastError;
  final List<String> notes;

  factory AgoraAgentSessionInfo.fromJson(Map<String, dynamic> json) {
    final rawNotes = json['notes'];
    final rawUids = json['remoteRtcUids'];

    return AgoraAgentSessionInfo(
      agentRtcUid: _stringOf(json['agentRtcUid']),
      remoteRtcUids: rawUids is List
          ? rawUids.map((item) => _stringOf(item)).where((e) => e.isNotEmpty).toList()
          : const [],
      agentId: _nullableStringOf(json['agentId']),
      status: _stringOf(json['status'], fallback: 'pending_backend_agent_start'),
      lastError: _nullableStringOf(json['lastError']),
      notes: rawNotes is List
          ? rawNotes.map((item) => _stringOf(item)).where((e) => e.isNotEmpty).toList()
          : const [],
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

int _intOf(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
