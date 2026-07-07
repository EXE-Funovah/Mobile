import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../shared/widgets/themed_card.dart';

/// tone key → màu chữ/nền cho badge (khớp `tone()` trong design).
({Color fg, Color bg}) adminTone(AppTokens t, String key) {
  switch (key) {
    case 'ok':
      return (fg: t.ok, bg: t.ok.withValues(alpha: 0.12));
    case 'accent':
      return (fg: t.accent, bg: t.accentSoft);
    case 'primary':
      return (fg: t.primary, bg: t.primarySoft);
    case 'down':
      return (fg: t.danger, bg: t.danger.withValues(alpha: 0.12));
    default:
      return (fg: t.ink2, bg: t.surfaceSunken);
  }
}

/// Scaffold cho màn chi tiết (push): app bar back + title, body cuộn gap 14.
class AdminDetailScaffold extends ConsumerWidget {
  final String title;
  final List<Widget> children;
  const AdminDetailScaffold({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: t.appBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: Row(
                children: [
                  Material(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: t.line),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: t.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: t.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                itemCount: children.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (_, i) => children[i],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminBadge extends StatelessWidget {
  final AppTokens t;
  final String label;
  final String tone;
  final IconData? icon;
  const AdminBadge({
    super.key,
    required this.t,
    required this.label,
    this.tone = 'muted',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = adminTone(t, tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c.fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: c.fg,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final double size;
  const AdminAvatar({
    super.key,
    required this.name,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? '?'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .map((e) => e[0])
              .take(2)
              .join()
              .toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: color,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

/// Nhãn section (uppercase muted) trong màn detail.
class AdminSectionLabel extends StatelessWidget {
  final AppTokens t;
  final String label;
  final Widget? trailing;
  const AdminSectionLabel({
    super.key,
    required this.t,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: t.inkMuted,
            ),
          ),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

/// Section label + card (khớp DGroup).
class AdminGroup extends StatelessWidget {
  final AppTokens t;
  final String label;
  final Widget child;
  final EdgeInsets padding;
  const AdminGroup({
    super.key,
    required this.t,
    required this.label,
    required this.child,
    this.padding = const EdgeInsets.all(15),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminSectionLabel(t: t, label: label),
        ThemedCard(padding: padding, child: child),
      ],
    );
  }
}

class AdminInfoRow extends StatelessWidget {
  final AppTokens t;
  final String label;
  final Widget value;
  final bool mono;
  const AdminInfoRow({
    super.key,
    required this.t,
    required this.label,
    required this.value,
    this.mono = false,
  });

  static Widget text(AppTokens t, String label, String value, {bool mono = false}) =>
      AdminInfoRow(
        t: t,
        label: label,
        mono: mono,
        value: Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: t.ink,
            fontFamily: mono ? 'monospace' : null,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: t.inkMuted,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Align(alignment: Alignment.centerRight, child: value)),
        ],
      ),
    );
  }
}

/// Danh sách InfoRow ngăn nhau bằng divider.
class AdminRows extends StatelessWidget {
  final AppTokens t;
  final List<Widget> children;
  const AdminRows({super.key, required this.t, required this.children});

  @override
  Widget build(BuildContext context) {
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) out.add(Divider(height: 1, color: t.line));
      out.add(children[i]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: out);
  }
}

class AdminStatTile extends StatelessWidget {
  final AppTokens t;
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const AdminStatTile({
    super.key,
    required this.t,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: t.surfaceSunken,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: t.ink,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: t.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card người liên quan (chủ sở hữu / giáo viên / người mua) → bấm sang chi tiết.
class AdminPersonCard extends StatelessWidget {
  final AppTokens t;
  final String name;
  final String email;
  final String? meta;
  final bool deleted;
  final Color? color;
  final VoidCallback? onTap;
  const AdminPersonCard({
    super.key,
    required this.t,
    required this.name,
    required this.email,
    this.meta,
    this.deleted = false,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          AdminAvatar(name: name, color: color ?? t.primary, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: t.ink,
                        ),
                      ),
                    ),
                    if (deleted) ...[
                      const SizedBox(width: 7),
                      AdminBadge(t: t, label: 'Đã xoá', tone: 'down'),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: t.inkMuted,
                  ),
                ),
                if (meta != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    meta!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: t.ink2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right, size: 20, color: t.inkMuted),
        ],
      ),
    );
  }
}

/// Ô tìm kiếm (submit-to-search).
class AdminSearchField extends StatelessWidget {
  final AppTokens t;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  const AdminSearchField({
    super.key,
    required this.t,
    required this.hint,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: t.line),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (v) => onSubmit(v.trim()),
        style: TextStyle(color: t.ink, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: t.inkMuted, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: t.inkMuted, size: 19),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }
}

/// Segmented control full-width.
class AdminSeg extends StatelessWidget {
  final AppTokens t;
  final List<String> items;
  final int active;
  final ValueChanged<int> onChange;
  const AdminSeg({
    super.key,
    required this.t,
    required this.items,
    required this.active,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.surfaceSunken,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChange(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == active ? t.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    items[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: i == active ? Colors.white : t.inkMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Hàng chip lọc cuộn ngang. [values] song song [labels]; giá trị đang chọn.
class AdminChips extends StatelessWidget {
  final AppTokens t;
  final List<String> labels;
  final List<String?> values;
  final String? selected;
  final ValueChanged<String?> onSelect;
  const AdminChips({
    super.key,
    required this.t,
    required this.labels,
    required this.values,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(values[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: selected == values[i] ? t.primary : t.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected == values[i] ? t.primary : t.line,
                    ),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected == values[i] ? Colors.white : t.ink2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Trạng thái list dùng chung: loading / error / footer đếm.
class AdminAsyncSlivers {
  static Widget loading() => const Padding(
    padding: EdgeInsets.only(top: 50),
    child: Center(child: CircularProgressIndicator()),
  );

  static Widget error(AppTokens t, Object e, VoidCallback onRetry) => Padding(
    padding: const EdgeInsets.only(top: 40),
    child: Column(
      children: [
        Icon(Icons.error_outline, color: t.danger, size: 40),
        const SizedBox(height: 12),
        Text(
          '$e'.replaceFirst('Exception: ', ''),
          textAlign: TextAlign.center,
          style: TextStyle(color: t.ink2),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    ),
  );

  static Widget footer(AppTokens t, int shown, int total) => shown >= total
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Center(
            child: Text(
              'Đang hiển thị $shown/$total',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: t.inkMuted,
              ),
            ),
          ),
        );
}
