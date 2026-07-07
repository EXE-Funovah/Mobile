import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../shared/widgets/themed_card.dart';
import '../data/admin_models.dart';
import '../providers/admin_providers.dart';
import '../utils/admin_format.dart';
import '../widgets/admin_ui.dart';
import 'admin_order_detail_screen.dart';

/// A. Chi tiết tài khoản (GET /users/{id}).
class AdminUserDetailScreen extends ConsumerWidget {
  final int userId;
  final Color avatarColor;
  const AdminUserDetailScreen({
    super.key,
    required this.userId,
    this.avatarColor = const Color(0xFF7A5AD9),
  });

  String _orderTone(String s) => switch (s) {
    'Paid' => 'ok',
    'Pending' => 'accent',
    _ => 'down',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final async = ref.watch(adminUserDetailProvider(userId));

    return async.when(
      loading: () => Scaffold(
        backgroundColor: t.appBg,
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => AdminDetailScaffold(
        title: 'Chi tiết tài khoản',
        children: [AdminAsyncSlivers.error(t, e, () => ref.invalidate(adminUserDetailProvider(userId)))],
      ),
      data: (u) => _body(context, ref, t, u),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, AppTokens t, AdminUserDetail u) {
    final mins = (u.totalLearningSeconds / 60).round();
    final acc = u.totalQuestionsAnswered == 0
        ? 0
        : (u.totalCorrectAnswers / u.totalQuestionsAnswered * 100).round();
    final subLabel = switch (u.subscriptionStatus) {
      'Premium' => 'Premium · hết hạn ${fmtDate(u.premiumExpiresAt)}',
      'Expired' => 'Premium hết hạn',
      _ => 'Freemium',
    };

    return AdminDetailScaffold(
      title: 'Chi tiết tài khoản',
      children: [
        // Header
        ThemedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AdminAvatar(name: u.fullName, color: avatarColor, size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.fullName.isEmpty ? 'Chưa đặt tên' : u.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: t.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          u.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: t.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  AdminBadge(t: t, label: _roleVi(u.role), icon: Icons.person),
                  AdminBadge(
                    t: t,
                    label: subLabel,
                    tone: u.subscriptionStatus == 'Premium'
                        ? 'accent'
                        : u.subscriptionStatus == 'Expired'
                        ? 'down'
                        : 'muted',
                    icon: Icons.auto_awesome,
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Padding(
                padding: const EdgeInsets.only(top: 13),
                child: Row(
                  children: [
                    _miniStat(t, Icons.calendar_today, fmtDate(u.createdAt), 'tạo'),
                    const SizedBox(width: 18),
                    _miniStat(t, Icons.schedule, fmtDate(u.lastActiveDate), 'hoạt động'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Học tập
        _tileGroup(t, 'Học tập', [
          AdminStatTile(t: t, icon: Icons.bolt, value: vnd(u.xp), label: 'Điểm XP', color: t.primary),
          AdminStatTile(t: t, icon: Icons.local_fire_department, value: '${u.currentStreak} ngày', label: 'Chuỗi streak', color: t.accent),
          AdminStatTile(t: t, icon: Icons.schedule, value: vnd(mins), label: 'Phút học', color: const Color(0xFF5BAED4)),
          AdminStatTile(t: t, icon: Icons.gps_fixed, value: '$acc%', label: 'Chính xác · ${vnd(u.totalCorrectAnswers)}/${vnd(u.totalQuestionsAnswered)}', color: t.ok),
        ]),
        // Nội dung
        _tileGroup(t, 'Nội dung đã tạo', [
          AdminStatTile(t: t, icon: Icons.description, value: '${u.documentCount}', label: 'Tài liệu · ${u.documentsProcessed} đã xử lý', color: t.primary),
          AdminStatTile(t: t, icon: Icons.assignment, value: '${u.quizCount}', label: 'Quiz', color: t.primary),
          AdminStatTile(t: t, icon: Icons.layers, value: '${u.flashcardCount}', label: 'Flashcard', color: t.accent),
          AdminStatTile(t: t, icon: Icons.sports_esports, value: '${u.liveSessionCount}', label: 'Phiên live', color: const Color(0xFF7A5AD9)),
        ]),
        // Thanh toán
        AdminGroup(
          t: t,
          label: 'Thanh toán',
          child: Column(
            children: [
              AdminRows(
                t: t,
                children: [
                  AdminInfoRow.text(t, 'Số đơn', '${u.paymentOrderCount} đơn'),
                  AdminInfoRow(
                    t: t,
                    label: 'Đơn gần nhất',
                    value: u.latestPaymentStatus == null
                        ? Text('—', style: TextStyle(color: t.inkMuted, fontWeight: FontWeight.w800))
                        : AdminBadge(
                            t: t,
                            label: orderStatusName(u.latestPaymentStatus!),
                            tone: _orderTone(u.latestPaymentStatus!),
                          ),
                  ),
                  AdminInfoRow.text(t, 'Gói', u.latestPaymentPlanCode == null ? '—' : planName(u.latestPaymentPlanCode!)),
                  AdminInfoRow.text(t, 'Ngày', fmtDate(u.latestPaymentAt)),
                ],
              ),
              if (u.paymentOrderCount > 0) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openLatestOrder(context, ref, u.email),
                    style: FilledButton.styleFrom(
                      backgroundColor: t.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label: const Text(
                      'Xem đơn gần nhất',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openLatestOrder(
    BuildContext context,
    WidgetRef ref,
    String email,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final res = await ref.read(adminUserOrdersProvider(email).future);
      if (!context.mounted) return;
      Navigator.of(context).pop(); // đóng loading
      if (res.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy đơn của tài khoản này.')),
        );
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AdminOrderDetailScreen(order: res.items.first),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
    }
  }

  Widget _tileGroup(AppTokens t, String label, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminSectionLabel(t: t, label: label),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.55,
          children: tiles,
        ),
      ],
    );
  }

  Widget _miniStat(AppTokens t, IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: t.inkMuted),
        const SizedBox(width: 7),
        Text(
          value,
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: t.ink),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11, color: t.inkMuted)),
      ],
    );
  }

  String _roleVi(String r) => switch (r) {
    'Teacher' => 'Giáo viên',
    'Student' => 'Học sinh',
    'Parent' => 'Phụ huynh',
    'Admin' => 'Admin',
    _ => r,
  };
}
