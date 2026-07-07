import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../shared/widgets/student_bottom_nav.dart';
import '../../mascot_chat/pages/mascot_ai_page.dart';
import 'student_home_tab.dart';
import 'student_library_tab.dart';
import 'student_profile_tab.dart';
import 'student_progress_tab.dart';
import '../providers/nav_providers.dart';

class StudentShell extends ConsumerStatefulWidget {
  const StudentShell({super.key});

  @override
  ConsumerState<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends ConsumerState<StudentShell> {
  NavTab _tab = NavTab.home;
  bool _voiceOpen = false;
  DateTime? _lastBackPress;

  void _openVoice() => setState(() => _voiceOpen = true);

  /// Xử lý nút back của Android: đừng thoát app ngay.
  /// - Đang mở voice → đóng voice.
  /// - Không ở tab Home → về tab Home.
  /// - Ở tab Home → nhấn 2 lần trong 2 giây mới thoát.
  void _handleBack() {
    if (_voiceOpen) {
      setState(() => _voiceOpen = false);
      return;
    }
    if (_tab != NavTab.home) {
      setState(() => _tab = NavTab.home);
      return;
    }
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Nhấn back lần nữa để thoát'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);

    // Cho phép màn khác (vd. sau khi xuất bản flashcard) yêu cầu chuyển tab.
    ref.listen(studentTabRequestProvider, (prev, next) {
      if (next != null) {
        setState(() => _tab = next);
        ref.read(studentTabRequestProvider.notifier).state = null;
      }
    });

    if (_voiceOpen) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _handleBack();
        },
        child: MascotAiPage(onBack: () => setState(() => _voiceOpen = false)),
      );
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
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
          // FAB overlay — đẩy lên 8px trên bottom nav (vừa nhô, không che label)
          Positioned(
            top: -8,
            child: VoiceFab(active: _tab == NavTab.voice, onTap: _openVoice),
          ),
        ],
      ),
      ),
    );
  }
}
