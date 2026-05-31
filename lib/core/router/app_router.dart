import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/user.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/auth/pages/splash_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/quiz/pages/create_quiz_from_doc_page.dart';
import '../../features/student/pages/student_shell.dart';
import '../../features/teacher/pages/teacher_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.uri.path;
      final loggedIn = auth.isAuthenticated;

      // Khi vừa khởi động, chưa biết auth → ở splash
      if (loc == '/splash') {
        if (!loggedIn) return '/login';
        return _homeFor(auth.role);
      }

      final isAuthRoute = loc == '/login' || loc == '/register';
      if (!loggedIn && !isAuthRoute) return '/login';
      if (loggedIn && isAuthRoute) return _homeFor(auth.role);
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
      GoRoute(path: '/student', builder: (_, _) => const StudentShell()),
      GoRoute(path: '/teacher', builder: (_, _) => const TeacherShell()),
      GoRoute(
        path: '/quiz/from-doc',
        builder: (_, _) => const CreateQuizFromDocPage(),
      ),
      GoRoute(
        path: '/parent',
        builder: (_, _) => const Scaffold(
          body: Center(child: Text('Parent UI sắp ra mắt')),
        ),
      ),
    ],
  );
});

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

/// Listen vào authProvider để GoRouter tự refresh khi login/logout.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(authProvider, (_, _) => notifyListeners());
  }
}
