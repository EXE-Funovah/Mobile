import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/network_error_formatter.dart';
import '../../../data/api/mascot_live_api.dart';
import '../../../data/models/mascot_live_session.dart';
import '../widgets/voice_message_feed.dart';

class VoiceChatPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  /// Khi `true`, ẩn header riêng (back/Sumadi/reconnect) vì được nhúng trong
  /// [MascotAiPage] — page cha đã có thanh tiêu đề + toggle Voice/Chat.
  final bool embedded;

  const VoiceChatPage({super.key, required this.onBack, this.embedded = false});

  @override
  ConsumerState<VoiceChatPage> createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends ConsumerState<VoiceChatPage>
    with SingleTickerProviderStateMixin {
  static const List<String> _defaultSuggestions = [
    'Cho ví dụ dễ hiểu',
    'Giải thích lại ngắn hơn',
    'Tạo 3 câu hỏi ôn tập',
  ];

  late final AnimationController _ctl;

  final List<VoiceChatMessage> _messages = [];

  bool _disposing = false;
  bool _listening = false;
  bool _joining = false;
  bool _connected = false;
  bool _remoteJoined = false;
  bool _micEnabled = false;
  bool _speaking = false;
  String _statusText = 'Đang chuẩn bị kết nối Sumadi…';
  String? _errorText;
  MascotLiveSession? _session;
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _bootstrapRealtime();
  }

  @override
  void dispose() {
    _disposing = true;
    unawaited(_teardownRealtime());
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _bootstrapRealtime() async {
    _appendSystemMessage('Đang tạo phiên giọng nói với Sumadi…');
    await _startRealtimeSession();
  }

  Future<void> _startRealtimeSession() async {
    if (_joining || _connected) return;

    setState(() {
      _joining = true;
      _errorText = null;
      _statusText = 'Đang xin quyền micro…';
    });

    try {
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        throw Exception('Bạn cần cấp quyền micro để trò chuyện với Sumadi.');
      }

      try {
        await Helper.setAndroidAudioConfiguration(
          AndroidAudioConfiguration.communication,
        );
      } catch (_) {}

      try {
        await Helper.setSpeakerphoneOn(true);
      } catch (_) {}

      if (!mounted) return;
      setState(() => _statusText = 'Đang tạo phiên trò chuyện với Sumadi…');

      final session = await MascotLiveApi.instance.createSession(
        displayName: 'Mascoteach learner',
        language: 'vi',
      );

      final peerConnection = await createPeerConnection({
        'sdpSemantics': 'unified-plan',
      });

      final localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': false,
      });

      for (final track in localStream.getTracks()) {
        await peerConnection.addTrack(track, localStream);
      }

      final dataChannel = await peerConnection.createDataChannel(
        session.connection.dataChannelLabel,
        RTCDataChannelInit()..ordered = true,
      );

      _wirePeerConnection(
        session: session,
        peerConnection: peerConnection,
        dataChannel: dataChannel,
      );

      final offer = await peerConnection.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      });

      await peerConnection.setLocalDescription(offer);

      final answerSdp = await MascotLiveApi.instance.exchangeRealtimeSdp(
        session: session,
        offerSdp: offer.sdp ?? '',
      );

      await peerConnection.setRemoteDescription(
        RTCSessionDescription(answerSdp, 'answer'),
      );

      if (!mounted) {
        await _disposeRealtimeObjects(
          peerConnection: peerConnection,
          dataChannel: dataChannel,
          localStream: localStream,
        );
        return;
      }

      setState(() {
        _session = session;
        _peerConnection = peerConnection;
        _dataChannel = dataChannel;
        _localStream = localStream;
        _connected = true;
        _listening = true;
        _micEnabled = true;
        _statusText = 'Sumadi đang nghe';
      });
      _appendSystemMessage('Đã kết nối giọng nói thời gian thực với Sumadi.');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = formatNetworkError(
          error,
          fallbackMessage: 'Không kết nối được Sumadi',
        );
        _statusText = 'Không kết nối được Sumadi';
      });
      _appendSystemMessage(_errorText ?? 'Không kết nối được Sumadi.');
      await _teardownRealtime(resetSessionOnly: false);
    } finally {
      if (mounted) {
        setState(() => _joining = false);
      }
    }
  }

  void _wirePeerConnection({
    required MascotLiveSession session,
    required RTCPeerConnection peerConnection,
    required RTCDataChannel dataChannel,
  }) {
    peerConnection.onTrack = (event) {
      if (!mounted || event.track.kind != 'audio') return;
      setState(() {
        _remoteJoined = true;
        _speaking = true;
        _statusText = 'Sumadi đang phản hồi…';
      });
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams.first;
      }
    };

    peerConnection.onConnectionState = (state) {
      if (!mounted) return;
      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
          setState(() => _statusText = 'Đang kết nối với Sumadi…');
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          setState(() {
            _connected = true;
            _remoteJoined = true;
            _statusText = _speaking
                ? 'Sumadi đang phản hồi…'
                : (_micEnabled ? 'Sumadi đang nghe' : 'Mic đang tắt');
          });
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          setState(() => _statusText = 'Kết nối bị gián đoạn');
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          setState(() => _statusText = 'Kết nối thất bại');
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          setState(() => _statusText = 'Đã đóng phiên giọng nói');
          break;
        default:
          break;
      }
    };

    dataChannel.onDataChannelState = (state) {
      if (!mounted) return;
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        _appendSystemMessage('Kênh điều khiển giọng nói đã sẵn sàng.');
        setState(() {
          _listening = _micEnabled;
          _statusText = _speaking
              ? 'Sumadi đang phản hồi…'
              : (_micEnabled ? 'Sumadi đang nghe' : 'Mic đang tắt');
        });
      }
    };

    dataChannel.onMessage = (message) {
      if (message.isBinary) return;
      _handleRealtimeEvent(message.text, session);
    };
  }

  void _handleRealtimeEvent(String raw, MascotLiveSession session) {
    try {
      final event = jsonDecode(raw);
      if (event is! Map<String, dynamic>) return;

      final type = event['type']?.toString() ?? '';
      if (!mounted) return;

      switch (type) {
        case 'response.created':
        case 'response.output_item.added':
          setState(() {
            _speaking = true;
            _listening = false;
            _remoteJoined = true;
            _statusText = 'Sumadi đang phản hồi…';
          });
          break;
        case 'response.done':
        case 'response.completed':
        case 'output_audio_buffer.stopped':
          setState(() {
            _speaking = false;
            _listening = _micEnabled;
            _statusText = _micEnabled ? 'Sumadi đang nghe' : 'Mic đang tắt';
          });
          break;
        case 'error':
          final message =
              (event['error'] is Map
                      ? (event['error'] as Map)['message']
                      : null)
                  ?.toString() ??
              'Sumadi gặp lỗi';
          setState(() {
            _errorText = message;
            _statusText = message;
          });
          _appendSystemMessage(message);
          break;
        case 'response.audio_transcript.done':
        case 'response.output_text.done':
          final text =
              event['text']?.toString().trim() ??
              (event['transcript']?.toString().trim() ?? '');
          if (text.isNotEmpty) {
            _appendAssistantMessage(text);
          }
          break;
        default:
          break;
      }
    } catch (_) {
      // Ignore unrecognized realtime events.
    }
  }

  Future<void> _teardownRealtime({bool resetSessionOnly = true}) async {
    final peerConnection = _peerConnection;
    final dataChannel = _dataChannel;
    final localStream = _localStream;
    final remoteStream = _remoteStream;
    final sessionId = _session?.sessionId;

    _peerConnection = null;
    _dataChannel = null;
    _localStream = null;
    _remoteStream = null;

    if (mounted && !_disposing) {
      setState(() {
        _connected = false;
        _listening = false;
        _micEnabled = false;
        _remoteJoined = false;
        _speaking = false;
        if (resetSessionOnly) {
          _session = null;
        }
      });
    } else if (resetSessionOnly) {
      _session = null;
    }

    await _disposeRealtimeObjects(
      peerConnection: peerConnection,
      dataChannel: dataChannel,
      localStream: localStream,
      remoteStream: remoteStream,
    );

    if (sessionId != null && sessionId.isNotEmpty) {
      try {
        await MascotLiveApi.instance.endSession(sessionId);
      } catch (_) {}
    }
  }

  Future<void> _disposeRealtimeObjects({
    RTCPeerConnection? peerConnection,
    RTCDataChannel? dataChannel,
    MediaStream? localStream,
    MediaStream? remoteStream,
  }) async {
    if (dataChannel != null) {
      try {
        await dataChannel.close();
      } catch (_) {}
    }

    if (localStream != null) {
      for (final track in localStream.getTracks()) {
        try {
          track.stop();
        } catch (_) {}
      }
      try {
        await localStream.dispose();
      } catch (_) {}
    }

    if (remoteStream != null) {
      for (final track in remoteStream.getTracks()) {
        try {
          track.stop();
        } catch (_) {}
      }
      try {
        await remoteStream.dispose();
      } catch (_) {}
    }

    if (peerConnection != null) {
      try {
        await peerConnection.close();
      } catch (_) {}
    }
  }

  Future<void> _toggleMicOrReconnect() async {
    if (_joining) return;

    if (!_connected) {
      await _startRealtimeSession();
      return;
    }

    final nextEnabled = !_micEnabled;
    for (final track
        in _localStream?.getAudioTracks() ?? const <MediaStreamTrack>[]) {
      track.enabled = nextEnabled;
    }
    if (!mounted) return;

    setState(() {
      _micEnabled = nextEnabled;
      _listening = nextEnabled && !_speaking;
      _statusText = nextEnabled ? 'Mic đang bật' : 'Mic đang tắt';
    });
  }

  Future<void> _closeVoicePage() async {
    await _teardownRealtime();
    if (!mounted) return;
    widget.onBack();
  }

  Future<void> _openPromptComposer() async {
    final controller = TextEditingController();
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Nhập lời nhắn cho Sumadi…',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(context).pop(controller.text.trim()),
                          child: const Text('Gửi'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    final prompt = text?.trim() ?? '';
    if (prompt.isEmpty) return;
    await _sendPrompt(prompt);
  }

  Future<void> _sendPrompt(String text) async {
    _appendUserMessage(text);

    if (mounted) {
      setState(() {
        _statusText = 'Đang gửi lời nhắn cho Sumadi…';
        _errorText = null;
      });
    }

    try {
      if (_dataChannel != null &&
          _dataChannel!.state == RTCDataChannelState.RTCDataChannelOpen) {
        _dataChannel!.send(
          RTCDataChannelMessage(
            jsonEncode({
              'type': 'conversation.item.create',
              'item': {
                'type': 'message',
                'role': 'user',
                'content': [
                  {'type': 'input_text', 'text': text},
                ],
              },
            }),
          ),
        );
        _dataChannel!.send(
          RTCDataChannelMessage(jsonEncode({'type': 'response.create'})),
        );
        if (!mounted) return;
        setState(() {
          _statusText = 'Đã gửi lời nhắn cho Sumadi';
        });
        return;
      }

      final reply = await MascotLiveApi.instance.sendChatMessage(
        text,
        history: _buildChatHistory(),
      );
      _appendAssistantMessage(reply);
      if (!mounted) return;
      setState(() {
        _statusText = 'Đã gửi prompt cho Sumadi';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = formatNetworkError(
          error,
          fallbackMessage: 'Không gửi được prompt',
        );
        _statusText = 'Không gửi được prompt';
      });
      _appendSystemMessage(_errorText ?? 'Không gửi được prompt');
    }
  }

  List<Map<String, String>> _buildChatHistory() {
    return _messages
        .where((message) => !message.isSystem)
        .take(8)
        .map(
          (message) => {
            'role': message.role == VoiceChatMessageRole.user
                ? 'user'
                : 'assistant',
            'content': message.text,
          },
        )
        .toList();
  }

  void _appendUserMessage(String text) => _appendMessage(
    VoiceChatMessage(role: VoiceChatMessageRole.user, text: text),
  );

  void _appendAssistantMessage(String text) => _appendMessage(
    VoiceChatMessage(role: VoiceChatMessageRole.assistant, text: text),
  );

  void _appendSystemMessage(String text) => _appendMessage(
    VoiceChatMessage(role: VoiceChatMessageRole.system, text: text),
  );

  void _appendMessage(VoiceChatMessage message) {
    if (!mounted) return;
    setState(() {
      _messages.add(message);
      if (_messages.length > 8) {
        _messages.removeRange(0, _messages.length - 8);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    final statusText = _errorText ?? _statusText;
    final aiSubtitle = _session == null
        ? 'Sumadi chưa sẵn sàng'
        : _remoteJoined
        ? 'Đã kết nối với Sumadi'
        : 'Đang chờ Sumadi phản hồi';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: t.heroGradient),
        child: SafeArea(
          child: Column(
            children: [
              if (!widget.embedded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
                  child: Row(
                    children: [
                      _CircleBtn(
                        icon: Icons.arrow_back_ios_new,
                        onTap: _closeVoicePage,
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          const Text(
                            'Sumadi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            aiSubtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _CircleBtn(
                        icon: _remoteJoined ? Icons.graphic_eq : Icons.bolt,
                        onTap: _joining ? () {} : _startRealtimeSession,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_listening)
                              ...List.generate(3, (i) {
                                return Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.35,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                    )
                                    .animate(onPlay: (c) => c.repeat())
                                    .scale(
                                      duration: 2400.ms,
                                      delay: (i * 800).ms,
                                      begin: const Offset(0.45, 0.45),
                                      end: const Offset(1.4, 1.4),
                                      curve: Curves.easeOut,
                                    )
                                    .fadeOut(
                                      delay: (i * 800 + 1200).ms,
                                      duration: 1200.ms,
                                    );
                              }),
                            Container(
                              width: 158,
                              height: 158,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.25),
                                    Colors.white.withValues(alpha: 0.05),
                                  ],
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x4D000000),
                                    blurRadius: 40,
                                    offset: Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child:
                                    Image.asset(
                                          (_remoteJoined || _speaking)
                                              ? 'assets/images/main-mascot-full.png'
                                              : 'assets/images/mascot-head.png',
                                        )
                                        .animate(
                                          onPlay: (c) =>
                                              c.repeat(reverse: true),
                                        )
                                        .moveY(
                                          duration: 2600.ms,
                                          begin: 0,
                                          end: -6,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 96),
                        child: SingleChildScrollView(
                          child: Text(
                            statusText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 40,
                        child: AnimatedBuilder(
                          animation: _ctl,
                          builder: (_, _) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(28, (i) {
                                final tick = _ctl.value * 10;
                                final h = _listening
                                    ? 6 + (sin(tick * 0.7 + i * 0.7).abs() * 30)
                                    : _joining
                                    ? 6 +
                                          (sin(tick * 0.4 + i * 0.35).abs() *
                                              12)
                                    : 5 + (sin(i.toDouble()).abs() * 8);
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 1.5,
                                  ),
                                  width: 3,
                                  height: h,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: VoiceMessageFeed(messages: _messages, ink: t.ink),
              ),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  children: _defaultSuggestions
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _sendPrompt(c),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                c,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SideBtn(
                      icon: Icons.send_rounded,
                      onTap: _openPromptComposer,
                    ),
                    GestureDetector(
                      onTap: _toggleMicOrReconnect,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _micEnabled ? Colors.white : t.accent,
                          boxShadow: [
                            BoxShadow(
                              color: _micEnabled
                                  ? Colors.white.withValues(alpha: 0.18)
                                  : t.accent.withValues(alpha: 0.25),
                              blurRadius: 0,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          _connected
                              ? (_micEnabled
                                    ? Icons.mic_rounded
                                    : Icons.mic_off_rounded)
                              : Icons.power_settings_new_rounded,
                          size: 32,
                          color: _micEnabled ? t.primaryDeep : Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _closeVoicePage,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: t.danger.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _SideBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SideBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
