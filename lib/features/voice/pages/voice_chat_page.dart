import 'dart:async';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utils/network_error_formatter.dart';
import '../../../data/api/mascot_live_api.dart';
import '../../../data/models/mascot_live_session.dart';
import '../../../core/theme/theme_provider.dart';
import '../widgets/voice_message_feed.dart';

class VoiceChatPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  const VoiceChatPage({super.key, required this.onBack});

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

  bool _listening = false;
  bool _joining = false;
  bool _connected = false;
  bool _remoteJoined = false;
  bool _micEnabled = false;
  int? _remoteUid;
  String _statusText = 'Đang chuẩn bị kết nối Agora…';
  String? _errorText;
  MascotLiveSession? _session;
  RtcEngine? _engine;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _bootstrapAgora();
  }

  @override
  void dispose() {
    unawaited(_teardownAgora());
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _bootstrapAgora() async {
    _appendSystemMessage('Đang tạo phiên giọng nói với Sumadi…');
    await _startAgoraSession();
  }

  Future<void> _startAgoraSession() async {
    if (_joining || _connected) return;

    setState(() {
      _joining = true;
      _errorText = null;
      _statusText = 'Đang xin quyền micro…';
    });

    try {
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        throw Exception('Bạn cần cấp quyền micro để dùng Agora voice.');
      }

      if (!mounted) return;
      setState(() => _statusText = 'Đang tạo phòng Agora…');

      final session = await MascotLiveApi.instance.createSession(
        displayName: 'Mascoteach learner',
        language: 'vi',
      );

      final engine = createAgoraRtcEngine();
      await engine.initialize(
        RtcEngineContext(
          appId: session.rtc.appId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onError: (err, msg) {
            if (!mounted) return;
            setState(() {
              _errorText = 'Agora error $err: $msg';
              _statusText = 'Agora gặp lỗi';
            });
          },
          onJoinChannelSuccess: (connection, elapsed) {
            if (!mounted) return;
            setState(() {
              _connected = true;
              _listening = true;
              _micEnabled = true;
              _statusText = 'Đã vào kênh Agora • Đang chờ Sumadi';
            });
            _appendSystemMessage(
              'Đã kết nối Agora channel "${session.rtc.channelName}".',
            );
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            if (!mounted) return;
            final isAgent = remoteUid.toString() == session.agent.agentRtcUid;
            setState(() {
              _remoteUid = remoteUid;
              _remoteJoined = true;
              _statusText = isAgent
                  ? 'Sumadi đã vào phòng Agora'
                  : 'Có người tham gia kênh Agora';
            });
            _appendAssistantMessage(
              isAgent
                  ? 'Sumadi đã tham gia phòng thoại. Bạn có thể bắt đầu nói.'
                  : 'Remote user $remoteUid đã tham gia kênh.',
            );
          },
          onUserOffline: (connection, remoteUid, reason) {
            if (!mounted) return;
            setState(() {
              if (_remoteUid == remoteUid) {
                _remoteUid = null;
                _remoteJoined = false;
              }
              _statusText = 'Remote user đã rời phòng';
            });
            _appendSystemMessage('Remote user $remoteUid đã rời kênh.');
          },
          onLeaveChannel: (connection, stats) {
            if (!mounted) return;
            setState(() {
              _connected = false;
              _listening = false;
              _micEnabled = false;
              _remoteJoined = false;
              _remoteUid = null;
              _statusText = 'Đã rời phòng Agora';
            });
          },
          onConnectionStateChanged: (connection, state, reason) {
            if (!mounted) return;
            if (state == ConnectionStateType.connectionStateConnecting) {
              setState(() => _statusText = 'Agora đang kết nối…');
            } else if (state ==
                ConnectionStateType.connectionStateReconnecting) {
              setState(() => _statusText = 'Agora đang kết nối lại…');
            } else if (state ==
                ConnectionStateType.connectionStateFailed) {
              setState(() => _statusText = 'Agora kết nối thất bại');
            }
          },
          onTokenPrivilegeWillExpire: (connection, token) {
            if (!mounted) return;
            _appendSystemMessage(
              'Agora token sắp hết hạn. Nếu test lâu, hãy vào lại phòng.',
            );
          },
        ),
      );

      await engine.enableAudio();
      await engine.disableVideo();
      await engine.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioChatroom,
      );
      await engine.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster,
      );

      await engine.joinChannel(
        token: session.rtc.token ?? '',
        channelId: session.rtc.channelName,
        uid: session.rtc.uid,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
          autoSubscribeAudio: true,
          autoSubscribeVideo: false,
        ),
      );

      if (!mounted) {
        await engine.leaveChannel();
        await engine.release();
        return;
      }

      setState(() {
        _session = session;
        _engine = engine;
        _statusText = 'Đang vào kênh Agora…';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = formatNetworkError(
          error,
          fallbackMessage: 'Không kết nối được Agora',
        );
        _statusText = 'Không kết nối được Agora';
      });
      _appendSystemMessage(_errorText ?? 'Không kết nối được Agora.');
    } finally {
      if (mounted) {
        setState(() => _joining = false);
      }
    }
  }

  Future<void> _teardownAgora() async {
    final engine = _engine;
    final sessionId = _session?.sessionId;

    _engine = null;
    _session = null;

    if (engine != null) {
      try {
        await engine.leaveChannel();
      } catch (_) {}
      try {
        await engine.release();
      } catch (_) {}
    }

    if (sessionId != null && sessionId.isNotEmpty) {
      try {
        await MascotLiveApi.instance.endSession(sessionId);
      } catch (_) {}
    }
  }

  Future<void> _toggleMicOrReconnect() async {
    if (_joining) return;

    if (!_connected) {
      await _startAgoraSession();
      return;
    }

    final nextEnabled = !_micEnabled;
    await _engine?.muteLocalAudioStream(!nextEnabled);
    if (!mounted) return;

    setState(() {
      _micEnabled = nextEnabled;
      _listening = nextEnabled;
      _statusText = nextEnabled ? 'Mic đang bật' : 'Mic đang tắt';
    });
  }

  Future<void> _closeVoicePage() async {
    await _teardownAgora();
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
        _statusText = 'Sumadi đang soạn câu trả lời…';
        _errorText = null;
      });
    }

    try {
      final reply = await MascotLiveApi.instance.sendChatMessage(
        text,
        history: _buildChatHistory(),
      );
      _appendAssistantMessage(reply);
      if (!mounted) return;
      setState(() {
        _statusText = _remoteJoined
            ? 'Sumadi đã vào phòng Agora'
            : 'Đã gửi prompt cho Sumadi';
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
            'role': message.role == VoiceChatMessageRole.user ? 'user' : 'assistant',
            'content': message.text,
          },
        )
        .toList();
  }

  void _appendUserMessage(String text) =>
      _appendMessage(VoiceChatMessage(role: VoiceChatMessageRole.user, text: text));

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
        ? 'Agora chưa sẵn sàng'
        : _remoteJoined
        ? 'Agora voice đã nối với Sumadi'
        : 'Đang chờ agent vào channel';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: t.heroGradient),
        child: SafeArea(
          child: Column(
            children: [
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
                      onTap: _joining ? () {} : _startAgoraSession,
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
                                child: Image.asset(
                                      _remoteJoined
                                          ? 'assets/images/mascot-speaking.png'
                                          : 'assets/images/mascot-head.png',
                                    )
                                    .animate(
                                      onPlay: (c) => c.repeat(reverse: true),
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
                      if (_session != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Channel: ${_session!.rtc.channelName}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
                                    ? 6 + (sin(tick * 0.4 + i * 0.35).abs() * 12)
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
                child: VoiceMessageFeed(
                  messages: _messages,
                  ink: t.ink,
                ),
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
