import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/onboarding_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/auth/pages/splash_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/quiz/pages/create_quiz_from_doc_page.dart';
import '../../features/quiz/pages/doc_detail_page.dart';
import '../../features/quiz/pages/quiz_play_page.dart';
import '../../features/quiz/pages/quiz_preview_page.dart';
import '../../features/quiz/pages/quiz_result_page.dart';
import '../../features/quiz/pages/upload_page.dart';
import '../../features/student/pages/account_page.dart';
import '../../features/student/pages/payment_page.dart';
import '../../features/student/pages/pricing_page.dart';
import '../../features/student/pages/settings_page.dart';
import '../../features/student/pages/student_shell.dart';

final onboardedProvider = FutureProvider<bool>((_) async {
  final sp = await SharedPreferences.getInstance();
  return sp.getBool('onboarded') ?? false;
});

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.uri.path;
      final loggedIn = auth.isAuthenticated;

      if (loc == '/splash') {
        // chờ async bootstrap; client guard sẽ chuyển sau
        return null;
      }

      const authRoutes = {'/login', '/register', '/onboarding'};
      if (!loggedIn && !authRoutes.contains(loc)) return '/login';
      if (loggedIn && authRoutes.contains(loc)) return _homeFor(auth.role);
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const _SplashGate()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
      GoRoute(path: '/student', builder: (_, _) => const StudentShell()),
      GoRoute(path: '/student/account', builder: (_, _) => const AccountPage()),
      GoRoute(
        path: '/student/settings',
        builder: (_, _) => const SettingsPage(),
      ),
      GoRoute(path: '/student/pricing', builder: (_, _) => const PricingPage()),
      GoRoute(
        path: '/student/payment',
        builder: (ctx, st) {
          final planId = st.uri.queryParameters['plan'] ?? 'monthly';
          return PaymentPage(planId: planId);
        },
      ),
      GoRoute(path: '/student/upload', builder: (_, _) => const UploadPage()),
      GoRoute(
        path: '/student/quiz-preview',
        builder: (ctx, st) {
          final args = st.extra;
          // Không có args (vd. deep link) thì quay về upload để bắt đầu lại.
          if (args is! QuizPreviewArgs) return const UploadPage();
          return QuizPreviewPage(args: args);
        },
      ),
      GoRoute(
        path: '/student/doc-detail',
        builder: (ctx, st) {
          final raw = st.uri.queryParameters['id'];
          final id = raw == null ? null : int.tryParse(raw);
          return DocDetailPage(documentId: id);
        },
      ),
      GoRoute(
        path: '/student/quiz',
        builder: (ctx, st) {
          final qidRaw = st.uri.queryParameters['quizId'];
          final docIdRaw = st.uri.queryParameters['documentId'];
          final quizId = qidRaw == null ? null : int.tryParse(qidRaw);
          final documentId = docIdRaw == null ? null : int.tryParse(docIdRaw);
          return QuizPlayPage(quizId: quizId, documentId: documentId);
        },
      ),
      GoRoute(
        path: '/student/quiz/result',
        builder: (ctx, st) {
          final score =
              int.tryParse(st.uri.queryParameters['score'] ?? '0') ?? 0;
          final total =
              int.tryParse(st.uri.queryParameters['total'] ?? '5') ?? 5;
          return QuizResultPage(score: score, total: total);
        },
      ),
      // Teacher dùng chung UI với Student (theo design handoff).
      // Sau này có thể tách riêng nếu cần.
      GoRoute(path: '/teacher', builder: (_, _) => const StudentShell()),
      GoRoute(
        path: '/teacher/quiz-from-doc',
        builder: (_, _) => const CreateQuizFromDocPage(),
      ),
      GoRoute(
        path: '/parent',
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Parent UI sắp ra mắt'))),
      ),
    ],
  );
});

/// Splash gate: kiểm tra onboarded + auth rồi redirect.
class _SplashGate extends ConsumerWidget {
  const _SplashGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final onboarded = ref.watch(onboardedProvider);

    onboarded.whenData((seen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        if (!seen) {
          context.go('/onboarding');
        } else if (auth.isAuthenticated) {
          context.go(_homeFor(auth.role));
        } else {
          context.go('/login');
        }
      });
    });

    return const SplashPage();
  }
}

String _homeFor(UserRole role) {
  switch (role) {
    case UserRole.teacher:
      return '/teacher';
    case UserRole.parent:
      return '/parent';
    case UserRole.student:
    case UserRole.unknown:
      return '/student';
  }
}

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(authProvider, (_, _) => notifyListeners());
  }
}
