import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: MascoteachApp()));
}

class MascoteachApp extends ConsumerWidget {
  const MascoteachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final tokens = ref.watch(themeProvider);
    return MaterialApp.router(
      title: 'Mascoteach',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(tokens),
      routerConfig: router,
    );
  }
}
