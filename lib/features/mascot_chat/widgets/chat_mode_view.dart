import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/mascot_avatar.dart';

class _Msg {
  final String text;
  final bool fromUser;
  _Msg(this.text, this.fromUser);
}

class ChatModeView extends StatefulWidget {
  const ChatModeView({super.key});

  @override
  State<ChatModeView> createState() => _ChatModeViewState();
}

class _ChatModeViewState extends State<ChatModeView> {
  final _ctl = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false;
  final List<_Msg> _messages = [
    _Msg(
        'Chào bạn! 🐾 Tôi là Mascot AI. Bạn cần giúp gì với bài giảng hôm nay?',
        false),
  ];

  void _send([String? quick]) {
    final t = (quick ?? _ctl.text).trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add(_Msg(t, true));
      _ctl.clear();
      _typing = true;
    });
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(_Msg(
          '(Sẽ trả lời thật khi nối với mascotChatService trên backend)',
          false,
        ));
      });
      _scrollToBottom();
    });
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
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (_, i) {
                if (i >= _messages.length) return const _TypingBubble();
                return _bubble(_messages[i]);
              },
            ),
          ),
          if (_messages.length <= 1) _quickSuggestions(),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: AppShadows.soft,
            ),
            child: SafeArea(
              top: false,
              child: Row(children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _ctl,
                      onSubmitted: (_) => _send(),
                      maxLines: 5,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn…',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
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
                      gradient: const LinearGradient(colors: [
                        AppColors.accentPink,
                        AppColors.accentOrange,
                      ]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentPink.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(_Msg m) {
    final isUser = m.fromUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const MascotAvatar(size: 32, bounce: false),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [AppColors.brandNavy, AppColors.brandBlue])
                    : null,
                color: isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: isUser ? null : AppShadows.soft,
                border: isUser ? null : Border.all(color: AppColors.border),
              ),
              child: Text(
                m.text,
                style: TextStyle(
                  color: isUser ? Colors.white : AppColors.ink,
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

  Widget _quickSuggestions() {
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
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s.$1, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        s.$2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.inkSecondary,
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
  const _TypingBubble();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        const MascotAvatar(size: 32, bounce: false),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(18),
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return Container(
                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.inkMuted,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .moveY(
                      duration: 600.ms,
                      delay: (i * 150).ms,
                      begin: 0,
                      end: -4,
                      curve: Curves.easeInOut)
                  .then()
                  .moveY(begin: -4, end: 0, duration: 600.ms);
            }),
          ),
        ),
      ]),
    );
  }
}
