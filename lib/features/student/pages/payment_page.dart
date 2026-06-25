import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../data/api/billing_api.dart';
import '../../shared/widgets/themed_card.dart';
import 'pricing_page.dart';

/// Phương thức thanh toán. Hiện chỉ PayOS (chuyển khoản/QR ngân hàng) chạy thật;
/// Thẻ + MoMo để preview ("Sắp có"), chưa tích hợp.
enum PaymentMethod { payos, card, momo }

class PaymentPage extends ConsumerStatefulWidget {
  final String planId; // 'monthly' | 'yearly'
  const PaymentPage({super.key, required this.planId});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  PaymentMethod _method =
      PaymentMethod.payos; // mặc định PayOS (cái duy nhất chạy)
  bool _processing = false;

  String get _planCode =>
      widget.planId == 'yearly' ? 'PRO_YEARLY' : 'PRO_MONTHLY';

  Future<void> _pay() async {
    if (_processing || _method != PaymentMethod.payos) return;
    setState(() => _processing = true);
    try {
      final url = await BillingApi.instance.createPaymentLink(_planCode);
      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) throw Exception('Không mở được trang thanh toán PayOS.');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    final plan = findPlanById(widget.planId);

    if (plan == null) {
      return Scaffold(
        backgroundColor: t.appBg,
        appBar: AppBar(
          backgroundColor: t.appBg,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: t.ink),
          ),
        ),
        body: const Center(child: Text('Gói không hợp lệ.')),
      );
    }

    return Scaffold(
      backgroundColor: t.appBg,
      appBar: AppBar(
        backgroundColor: t.appBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: t.ink),
        ),
        title: Text(
          'Thanh toán',
          style: TextStyle(
            color: t.ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                // ===== Đơn hàng =====
                _sectionTitle(t, 'Đơn hàng'),
                ThemedCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: t.accentSoft,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              Icons.workspace_premium,
                              color: t.accent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: t.ink,
                                  ),
                                ),
                                Text(
                                  plan.billingNote,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: t.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatVndPublic(plan.totalIfPaidNow),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: t.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: t.line, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Tổng cộng',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: t.ink,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formatVndPublic(plan.totalIfPaidNow),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: t.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ===== Phương thức thanh toán =====
                _sectionTitle(t, 'Phương thức thanh toán'),
                _methodTile(
                  t,
                  PaymentMethod.payos,
                  icon: Icons.qr_code_2,
                  iconColor: t.primary,
                  title: 'Chuyển khoản / QR ngân hàng',
                  subtitle: 'Quét QR hoặc chuyển khoản qua PayOS',
                ),
                const SizedBox(height: 10),
                _methodTile(
                  t,
                  PaymentMethod.card,
                  icon: Icons.credit_card,
                  iconColor: t.inkMuted,
                  title: 'Thẻ tín dụng / ghi nợ',
                  subtitle: 'Visa, Mastercard, JCB',
                  comingSoon: true,
                ),
                const SizedBox(height: 10),
                _methodTile(
                  t,
                  PaymentMethod.momo,
                  icon: Icons.account_balance_wallet,
                  iconColor: t.inkMuted,
                  title: 'Ví MoMo',
                  subtitle: 'Thanh toán qua app MoMo',
                  comingSoon: true,
                ),

                const SizedBox(height: 18),

                // ===== Ghi chú PayOS =====
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: t.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: t.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bạn sẽ được chuyển sang cổng PayOS để quét QR hoặc '
                          'chuyển khoản. Tài khoản tự động nâng cấp sau khi thanh '
                          'toán thành công (thường 1–2 phút).',
                          style: TextStyle(
                            color: t.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ===== Nút thanh toán =====
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            decoration: BoxDecoration(
              color: t.appBg,
              border: Border(top: BorderSide(color: t.line)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _processing ? null : _pay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: t.inkMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _processing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Thanh toán ${formatVndPublic(plan.totalIfPaidNow)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _methodTile(
    AppTokens t,
    PaymentMethod method, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool comingSoon = false,
  }) {
    final selected = _method == method;
    final enabled = !comingSoon;
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: GestureDetector(
        onTap: enabled ? () => setState(() => _method = method) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(t.cardRadius),
            border: Border.all(
              color: selected && enabled ? t.primary : t.line,
              width: selected && enabled ? 2 : 1,
            ),
            boxShadow: selected && enabled ? null : t.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: t.ink,
                            ),
                          ),
                        ),
                        if (comingSoon) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: t.surfaceSunken,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Sắp có',
                              style: TextStyle(
                                color: t.inkMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: t.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: selected && enabled ? t.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected && enabled ? t.primary : t.inkMuted,
                    width: 2,
                  ),
                ),
                child: selected && enabled
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(AppTokens t, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: t.inkMuted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
