import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';

class Pill extends ConsumerWidget {
  final Widget child;
  final int tint; // 0..3
  final EdgeInsets padding;

  const Pill({
    super.key,
    required this.child,
    this.tint = 0,
    this.padding = const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final bg = t.tints[tint.clamp(0, t.tints.length - 1)];
    final ink = t.tintInks[tint.clamp(0, t.tintInks.length - 1)];
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 11),
        child: IconTheme.merge(
          data: IconThemeData(color: ink, size: 13),
          child: child,
        ),
      ),
    );
  }
}
