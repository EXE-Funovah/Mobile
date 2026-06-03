import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../shared/widgets/student_bottom_nav.dart';
import '../../voice/pages/voice_chat_page.dart';
import 'student_home_tab.dart';
import 'student_library_tab.dart';
import 'student_profile_tab.dart';
import 'student_progress_tab.dart';

class StudentShell extends ConsumerStatefulWidget {
  const StudentShell({super.key});

  @override
  ConsumerState<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends ConsumerState<StudentShell> {
  NavTab _tab = NavTab.home;
  bool _voiceOpen = false;

  void _openVoice() => setState(() => _voiceOpen = true);

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);

    if (_voiceOpen) {
      return VoiceChatPage(onBack: () => setState(() => _voiceOpen = false));
    }

    Widget tabBody;
    switch (_tab) {
      case NavTab.home:
        tabBody = StudentHomeTab(onOpenVoice: _openVoice);
        break;
      case NavTab.library:
        tabBody = const StudentLibraryTab();
        break;
      case NavTab.voice:
        tabBody = const SizedBox.shrink();
        break;
      case NavTab.progress:
        tabBody = const StudentProgressTab();
        break;
      case NavTab.profile:
        tabBody = const StudentProfileTab();
        break;
    }

    return Scaffold(
      backgroundColor: t.appBg,
      body: SafeArea(bottom: false, child: tabBody),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          StudentBottomNav(
            active: _tab,
            onChange: (n) {
              if (n == NavTab.voice) {
                _openVoice();
              } else {
                setState(() => _tab = n);
              }
            },
          ),
          // FAB overlay — đẩy lên 28px trên bottom nav
          Positioned(
            top: -28,
            child: VoiceFab(active: _tab == NavTab.voice, onTap: _openVoice),
          ),
        ],
      ),
    );
  }
}
