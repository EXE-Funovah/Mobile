import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';

class SectionHead extends ConsumerWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHead({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: t.ink,
                letterSpacing: -0.1,
              ),
            ),
          ),
          if (action != null && action!.isNotEmpty)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: TextStyle(
                  color: t.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
