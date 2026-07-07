import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../auth/providers/user_profile_provider.dart';

// ============ Pricing constants ============
const _planMonth = 119000;
const _planYearPerMonth = 99000;
const _planYearTotal = _planYearPerMonth * 12; // 1.188.000đ/năm

int get _savePct =>
    ((1 - _planYearPerMonth / _planMonth) * 100).round(); // ~17%

String _vnd(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

// ============ Premium feature list ============
class _Feature {
  final IconData icon;
  final String title;
  final String desc;
  const _Feature(this.icon, this.title, this.desc);
}

const _premiumFeatures = <_Feature>[
  _Feature(
    Icons.all_inclusive,
    'Tài liệu không giới hạn',
    'Gói Free: tối đa 3 tài liệu',
  ),
  _Feature(
    Icons.mic,
    'Trò chuyện giọng nói với Sumadi',
    'Luyện nói cùng gia sư AI thả ga',
  ),
  _Feature(
    Icons.auto_awesome,
    'Giải thích chi tiết từng câu',
    'Hiểu sâu vì sao đúng / sai',
  ),
  _Feature(
    Icons.emoji_events,
    'Treasure Hunt cùng cả lớp',
    'Thi đấu theo PIN, bảng xếp hạng',
  ),
  _Feature(Icons.bolt, 'Ưu tiên xử lý nhanh hơn', 'Tạo câu hỏi nhanh gấp đôi'),
];

class PricingPage extends ConsumerStatefulWidget {
  const PricingPage({super.key});

  @override
  ConsumerState<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends ConsumerState<PricingPage> {
  bool _yearly = true; // mặc định Hàng năm (saving)

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    final user = ref.watch(userProfileProvider).valueOrNull;
    final isFree =
        (user?.subscriptionTier ?? 'Freemium').toLowerCase() == 'freemium';
    final perMonth = _yearly ? _planYearPerMonth : _planMonth;

    return Scaffold(
      backgroundColor: t.appBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Premium glow trên đầu
            Positioned(
              top: -90,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 320,
                  height: 220,
                  decoration: BoxDecoration(
                    color: t.accentSoft,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            Column(
              children: [
                // Close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [_CloseButton(onTap: () => context.pop())],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                    child: Column(
                      children: [
                        // Hero: mascot + crown
                        _Hero(t: t),
                        const SizedBox(height: 12),

                        // PREMIUM badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: t.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'PREMIUM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11.5,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Headline
                        Text(
                          'Mở khóa toàn bộ\nMascoteach',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: t.displayWeight,
                            color: t.ink,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 280,
                          child: Text(
                            'Học không giới hạn cùng Sumadi — tạo câu hỏi, '
                            'luyện nói và thi đấu thả ga.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: t.ink2,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Billing toggle
                        _BillingToggle(
                          yearly: _yearly,
                          onChange: (v) => setState(() => _yearly = v),
                        ),
                        const SizedBox(height: 14),

                        // Price card
                        _PriceCard(yearly: _yearly, perMonth: perMonth),
                        const SizedBox(height: 18),

                        // Features
                        Column(
                          children: _premiumFeatures
                              .asMap()
                              .entries
                              .map(
                                (e) => _FeatureRow(feature: e.value)
                                    .animate(delay: (60 * e.key).ms)
                                    .fadeIn(duration: 400.ms)
                                    .slideX(begin: 0.05, end: 0),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 8),

                        // Current plan note
                        if (isFree) _CurrentPlanNote(t: t),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // Sticky CTA
                _StickyCta(
                  yearly: _yearly,
                  onPressed: () => context.push(
                    '/student/payment?plan=${_yearly ? 'yearly' : 'monthly'}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============ Hero with mascot + crown ============
class _Hero extends StatelessWidget {
  final AppTokens t;
  const _Hero({required this.t});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 122,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Image.asset('assets/images/live-mascot-speaking-head.png', width: 118)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(duration: 2800.ms, begin: 0, end: -8),
          ),
          Positioned(
            top: -4,
            right: 16,
            child: Transform.rotate(
              angle: 0.21, // ~12 deg
              child: Icon(
                Icons.emoji_events,
                color: t.accent,
                size: 34,
                shadows: [
                  Shadow(
                    color: t.accent.withValues(alpha: 0.45),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Billing toggle pill ============
class _BillingToggle extends ConsumerWidget {
  final bool yearly;
  final ValueChanged<bool> onChange;
  const _BillingToggle({required this.yearly, required this.onChange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: t.surfaceSunken,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(child: _toggleBtn(t, true, 'Hàng năm', showSave: true)),
          const SizedBox(width: 6),
          Expanded(child: _toggleBtn(t, false, 'Hàng tháng')),
        ],
      ),
    );
  }

  Widget _toggleBtn(
    AppTokens t,
    bool forYearly,
    String label, {
    bool showSave = false,
  }) {
    final on = yearly == forYearly;
    return GestureDetector(
      onTap: () => onChange(forYearly),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: on ? t.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: on ? t.cardShadow : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: on ? t.ink : t.inkMuted,
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
              ),
            ),
            if (showSave) ...[
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: t.ok,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '-$_savePct%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============ Price card ============
class _PriceCard extends ConsumerWidget {
  final bool yearly;
  final int perMonth;
  const _PriceCard({required this.yearly, required this.perMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final saveAmount = (_planMonth - _planYearPerMonth) * 12;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.cardRadius),
        border: Border.all(color: t.accent, width: 2),
        boxShadow: t.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Text(
                  '${_vnd(perMonth)}đ',
                  key: ValueKey(perMonth),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: t.ink,
                    height: 1,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/tháng',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: t.inkMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Saving note (yearly) hoặc tagline (monthly)
          if (yearly)
            Wrap(
              spacing: 7,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${_vnd(_planMonth)}đ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: t.inkMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                Text(
                  'Tiết kiệm ${_vnd(saveAmount)}đ/năm',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: t.ok,
                  ),
                ),
              ],
            )
          else
            Text(
              'Thanh toán linh hoạt, hủy bất kỳ lúc nào.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t.ink2,
              ),
            ),

          // Yearly total
          if (yearly) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: t.line, style: BorderStyle.solid),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Tính theo năm',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: t.inkMuted,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_vnd(_planYearTotal)}đ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: t.ink,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '/năm',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: t.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============ Feature row ============
class _FeatureRow extends ConsumerWidget {
  final _Feature feature;
  const _FeatureRow({required this.feature});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 2),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: t.accent, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: t.ink,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  feature.desc,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: t.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: t.ok, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 15),
          ),
        ],
      ),
    );
  }
}

// ============ Current plan note ============
class _CurrentPlanNote extends StatelessWidget {
  final AppTokens t;
  const _CurrentPlanNote({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surfaceSunken,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.person_outline, color: t.inkMuted, size: 18),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: t.ink2,
                  height: 1.45,
                ),
                children: [
                  const TextSpan(text: 'Bạn đang dùng '),
                  TextSpan(
                    text: 'gói Free',
                    style: TextStyle(color: t.ink, fontWeight: FontWeight.w800),
                  ),
                  const TextSpan(text: ' — nâng cấp để bỏ mọi giới hạn.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Sticky CTA ============
class _StickyCta extends ConsumerWidget {
  final bool yearly;
  final VoidCallback onPressed;
  const _StickyCta({required this.yearly, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final priceLabel = yearly
        ? '${_vnd(_planYearTotal)}đ/năm'
        : '${_vnd(_planMonth)}đ/tháng';

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
      decoration: BoxDecoration(
        color: t.appBg,
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: t.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: t.accent.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Dùng thử Premium 7 ngày',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Sau dùng thử: $priceLabel · Hủy bất kỳ lúc nào',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: t.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Close button ============
class _CloseButton extends ConsumerWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: t.isDark ? Colors.white.withValues(alpha: 0.12) : t.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: t.isDark ? null : t.cardShadow,
        ),
        child: Icon(Icons.close, color: t.ink2, size: 20),
      ),
    );
  }
}

// ============ Public helpers cho payment_page.dart ============

class PricingPlan {
  final String id;
  final String name;
  final String billingNote;
  final int totalIfPaidNow;
  const PricingPlan({
    required this.id,
    required this.name,
    required this.billingNote,
    required this.totalIfPaidNow,
  });
}

const _publicPlans = <PricingPlan>[
  PricingPlan(
    id: 'monthly',
    name: 'Premium tháng',
    billingNote: 'Thanh toán hàng tháng',
    totalIfPaidNow: _planMonth,
  ),
  PricingPlan(
    id: 'yearly',
    name: 'Premium năm',
    billingNote: 'Thanh toán 1 lần / năm',
    totalIfPaidNow: _planYearTotal,
  ),
];

PricingPlan? findPlanById(String id) {
  for (final p in _publicPlans) {
    if (p.id == id) return p;
  }
  return null;
}

String formatVndPublic(int amount) => '${_vnd(amount)}đ';

