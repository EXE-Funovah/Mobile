import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';

class FlowHeader extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final Widget? trailing;

  const FlowHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        children: [
          _SquareBtn(icon: Icons.arrow_back_ios_new, onTap: onBack),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: t.ink,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: t.inkMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // ignore: use_null_aware_elements
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _SquareBtn extends ConsumerWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SquareBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: t.cardBorder,
            boxShadow: t.cardShadow,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: t.ink),
        ),
      ),
    );
  }
}
