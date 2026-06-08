import 'package:flutter/material.dart';

enum VoiceChatMessageRole { user, assistant, system }

class VoiceChatMessage {
  const VoiceChatMessage({required this.role, required this.text});

  final VoiceChatMessageRole role;
  final String text;

  bool get isSystem => role == VoiceChatMessageRole.system;
}

class VoiceMessageFeed extends StatelessWidget {
  const VoiceMessageFeed({
    super.key,
    required this.messages,
    required this.ink,
    this.emptyMessage = 'Khi agent vào channel, trạng thái Agora sẽ hiện ở đây.',
    this.maxHeight = 164,
  });

  final List<VoiceChatMessage> messages;
  final Color ink;
  final String emptyMessage;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final feedMessages = messages.isEmpty
        ? const [
            VoiceChatMessage(
              role: VoiceChatMessageRole.system,
              text: 'Khi agent vào channel, trạng thái Agora sẽ hiện ở đây.',
            ),
          ]
        : messages.reversed.toList(growable: false);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ListView.separated(
        reverse: true,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: feedMessages.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final message = feedMessages[index];
          return _VoiceBubble(message: message, ink: ink);
        },
      ),
    );
  }
}

class _VoiceBubble extends StatelessWidget {
  const _VoiceBubble({required this.message, required this.ink});

  final VoiceChatMessage message;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == VoiceChatMessageRole.user;
    final isSystem = message.role == VoiceChatMessageRole.system;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (isSystem ? 0.88 : 0.8),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isUser
                ? Colors.white
                : isSystem
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            border: isSystem
                ? Border.all(color: Colors.white.withValues(alpha: 0.16))
                : null,
            boxShadow: isUser
                ? const [
                    BoxShadow(
                      color: Color(0x2E000000),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: SelectableText(
            message.text,
            style: TextStyle(
              color: isUser ? ink : Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ),
      ),
    );
  }
}
