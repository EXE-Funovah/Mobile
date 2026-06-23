import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';

/// Card primitive khớp với `Card` từ ui.jsx — màu, bóng, border đều từ token.
class ThemedCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double? width;
  final Color? color;
  final BorderRadiusGeometry? radius;

  const ThemedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.width,
    this.color,
    this.radius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final r = radius ?? BorderRadius.circular(t.cardRadius);
    final container = Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? t.surface,
        borderRadius: r is BorderRadius
            ? r
            : BorderRadius.circular(t.cardRadius),
        boxShadow: t.cardShadow,
        border: t.cardBorder,
      ),
      child: child,
    );
    if (onTap == null) return container;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: r is BorderRadius
            ? r
            : BorderRadius.circular(t.cardRadius),
        child: container,
      ),
    );
  }
}
