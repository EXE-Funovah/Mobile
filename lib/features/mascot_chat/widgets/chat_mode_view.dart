import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/network_error_formatter.dart';
import '../../../data/api/mascot_live_api.dart';
import '../../shared/widgets/mascot_avatar.dart';

class _Msg {
  final String text;
  final bool fromUser;
  _Msg(this.text, this.fromUser);
}

class ChatModeView extends ConsumerStatefulWidget {
  const ChatModeView({super.key});

  @override
  ConsumerState<ChatModeView> createState() => _ChatModeViewState();
}

class _ChatModeViewState extends ConsumerState<ChatModeView> {
  final _ctl = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false;
  final List<_Msg> _messages = [
    _Msg(
      'Chào bạn! 🐾 Tôi là Mascot AI. Bạn cần giúp gì với bài giảng hôm nay?',
      false,
    ),
  ];

  Future<void> _send([String? quick]) async {
    final t = (quick ?? _ctl.text).trim();
    if (t.isEmpty || _typing) return;

    // Lịch sử hội thoại (8 lượt gần nhất) gửi kèm để giữ ngữ cảnh —
    // build TRƯỚC khi thêm tin nhắn hiện tại.
    final history = _buildHistory();

    setState(() {
      _messages.add(_Msg(t, true));
      _ctl.clear();
      _typing = true;
    });
    _scrollToBottom();

    try {
      final reply = await MascotLiveApi.instance.sendChatMessage(
        t,
        history: history,
      );
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(_Msg(reply, false));
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(
          _Msg(
            formatNetworkError(
              error,
              fallbackMessage:
                  'Xin lỗi, Sumadi chưa trả lời được. Thử lại nhé.',
            ),
            false,
          ),
        );
      });
    }
    _scrollToBottom();
  }

  /// Map các tin nhắn đã có sang định dạng history của AI service:
  /// [{role: 'user'|'assistant', content: '...'}], tối đa 8 lượt gần nhất.
  List<Map<String, String>> _buildHistory() {
    final recent = _messages.length > 8
        ? _messages.sublist(_messages.length - 8)
        : _messages;
    return recent
        .map(
          (m) => {'role': m.fromUser ? 'user' : 'assistant', 'content': m.text},
        )
        .toList();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    return Container(
      color: t.appBg,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (_, i) {
                if (i >= _messages.length) return _TypingBubble(tokens: t);
                return _bubble(_messages[i], t);
              },
            ),
          ),
          if (_messages.length <= 1) _quickSuggestions(t),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            decoration: BoxDecoration(
              color: t.surface,
              boxShadow: t.cardShadow,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: t.surface2,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: t.line),
                      ),
                      child: TextField(
                        controller: _ctl,
                        onSubmitted: (_) => _send(),
                        maxLines: 5,
                        minLines: 1,
                        style: TextStyle(color: t.ink, fontSize: 14.5),
                        cursorColor: t.primary,
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn…',
                          hintStyle: TextStyle(color: t.inkMuted),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: t.fabGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: t.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(_Msg m, AppTokens t) {
    final isUser = m.fromUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const MascotAvatar(size: 32, bounce: false),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                gradient: isUser ? t.heroGradient : null,
                color: isUser ? null : t.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: isUser ? null : t.cardShadow,
                border: isUser ? null : Border.all(color: t.line),
              ),
              child: Text(
                m.text,
                style: TextStyle(
                  color: isUser ? t.heroInk : t.ink,
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).moveY(begin: 8, end: 0);
  }

  Widget _quickSuggestions(AppTokens t) {
    final items = [
      ('📝', 'Tạo quiz toán lớp 4'),
      ('🎮', 'Gợi ý game cho 20 HS'),
      ('💡', 'Ý tưởng mở bài'),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((s) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _send(s.$2),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: t.line),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s.$1, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        s.$2,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: t.ink2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final AppTokens tokens;
  const _TypingBubble({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const MascotAvatar(size: 32, bounce: false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: tokens.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: tokens.inkMuted,
                        shape: BoxShape.circle,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .moveY(
                      duration: 600.ms,
                      delay: (i * 150).ms,
                      begin: 0,
                      end: -4,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .moveY(begin: -4, end: 0, duration: 600.ms);
              }),
            ),
          ),
        ],
      ),
    );
  }
}
