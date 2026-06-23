import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/features/voice/widgets/voice_message_feed.dart';

void main() {
  testWidgets('renders messages in a scrollable feed on small heights', (
    tester,
  ) async {
    final longMessage = List.filled(
      12,
      'DioException 502: upstream service failed.',
    ).join(' ');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 180,
              child: VoiceMessageFeed(
                ink: Colors.black,
                messages: [
                  VoiceChatMessage(
                    role: VoiceChatMessageRole.system,
                    text: longMessage,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ListView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
