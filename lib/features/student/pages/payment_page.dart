import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../shared/widgets/themed_card.dart';
import 'pricing_page.dart';

enum PaymentMethod { card, momo, bank }

class PaymentPage extends ConsumerStatefulWidget {
  final String planId;
  const PaymentPage({super.key, required this.planId});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  PaymentMethod _method = PaymentMethod.card;
  bool _processing = false;

  // Card fields
  final _cardNumber = TextEditingController();
  final _cardName = TextEditingController();
  final _cardExp = TextEditingController();
  final _cardCvv = TextEditingController();

  // MoMo
  final _momoPhone = TextEditingController();

  @override
  void dispose() {
    _cardNumber.dispose();
    _cardName.dispose();
    _cardExp.dispose();
    _cardCvv.dispose();
    _momoPhone.dispose();
    super.dispose();
  }

  Future<void> _submit(PricingPlan plan) async {
    setState(() => _processing = true);
    // Mock: chỉ giả lập độ trễ thanh toán
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _processing = false);
    _showSuccessSheet(plan);
  }

  void _showSuccessSheet(PricingPlan plan) {
    final t = ref.read(themeProvider);
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: t.ok.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: t.ok, size: 44),
            ).animate().scale(
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                  begin: const Offset(0.4, 0.4),
                  end: const Offset(1, 1),
                ),
            const SizedBox(height: 16),
            Text(
              'Thanh toán thành công!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: t.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Bạn đã nâng cấp lên ${plan.name}.\nChúc bạn học vui cùng Sumadi 🦝',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: t.ink2,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: t.surfaceSunken,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 16, color: t.inkMuted),
                  const SizedBox(width: 8),
                  Text(
                    'Đây là bản mock — chưa trừ tiền thật',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: t.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Pop payment + pricing → quay về account
                  context.go('/student/account');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: t.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Hoàn tất',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                // Order summary
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
                      _summaryRow(t, 'Tạm tính',
                          formatVndPublic(plan.totalIfPaidNow)),
                      const SizedBox(height: 6),
                      _summaryRow(t, 'VAT', 'Đã bao gồm'),
                      const SizedBox(height: 10),
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

                // Payment method
                _sectionTitle(t, 'Phương thức thanh toán'),
                _methodTile(
                  t,
                  PaymentMethod.card,
                  icon: Icons.credit_card,
                  iconColor: t.primary,
                  title: 'Thẻ tín dụng / ghi nợ',
                  subtitle: 'Visa, Mastercard, JCB',
                ),
                const SizedBox(height: 10),
                _methodTile(
                  t,
                  PaymentMethod.momo,
                  iconWidget: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA50064),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'MoMo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  title: 'Ví MoMo',
                  subtitle: 'Thanh toán nhanh qua app MoMo',
                ),
                const SizedBox(height: 10),
                _methodTile(
                  t,
                  PaymentMethod.bank,
                  icon: Icons.account_balance,
                  iconColor: t.accent,
                  title: 'Chuyển khoản ngân hàng',
                  subtitle: 'VietinBank, Vietcombank, ACB, …',
                ),

                const SizedBox(height: 18),

                // Form đặc thù từng method
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _methodForm(t),
                ),
              ],
            ),
          ),

          // Sticky pay button
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
                  onPressed: _processing ? null : () => _submit(plan),
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

  Widget _methodForm(AppTokens t) {
    switch (_method) {
      case PaymentMethod.card:
        return Column(
          key: const ValueKey('card'),
          children: [
            ThemedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _input(
                    t,
                    label: 'Số thẻ',
                    hint: '1234 5678 9012 3456',
                    controller: _cardNumber,
                    keyboard: TextInputType.number,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _CardNumberFormatter(),
                      LengthLimitingTextInputFormatter(19),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _input(
                    t,
                    label: 'Tên chủ thẻ',
                    hint: 'NGUYEN VAN A',
                    controller: _cardName,
                    formatters: [_UpperCaseTextFormatter()],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _input(
                          t,
                          label: 'MM/YY',
                          hint: '12/27',
                          controller: _cardExp,
                          keyboard: TextInputType.number,
                          formatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ExpFormatter(),
                            LengthLimitingTextInputFormatter(5),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _input(
                          t,
                          label: 'CVV',
                          hint: '123',
                          controller: _cardCvv,
                          obscure: true,
                          keyboard: TextInputType.number,
                          formatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.lock_outline, size: 14, color: t.inkMuted),
                      const SizedBox(width: 5),
                      Text(
                        'Bảo mật theo chuẩn PCI-DSS',
                        style: TextStyle(
                          fontSize: 11,
                          color: t.inkMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );

      case PaymentMethod.momo:
        return Column(
          key: const ValueKey('momo'),
          children: [
            ThemedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _input(
                    t,
                    label: 'Số điện thoại MoMo',
                    hint: '09xx xxx xxx',
                    controller: _momoPhone,
                    keyboard: TextInputType.phone,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE6F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.smartphone,
                          color: Color(0xFFA50064),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sau khi bấm "Thanh toán", mở app MoMo để xác nhận.',
                            style: TextStyle(
                              color: Color(0xFFA50064),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case PaymentMethod.bank:
        return Column(
          key: const ValueKey('bank'),
          children: [
            ThemedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chuyển khoản đến',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: t.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _bankRow(t, 'Ngân hàng', 'VietinBank — CN HCM'),
                  _bankRow(t, 'Số tài khoản', '101 0888 1234'),
                  _bankRow(t, 'Chủ tài khoản', 'CONG TY MASCOTEACH'),
                  _bankRow(t, 'Nội dung', 'MTC ${DateTime.now().millisecondsSinceEpoch ~/ 1000}'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: t.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: t.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tài khoản sẽ nâng cấp tự động sau khi xác nhận thanh toán (1–10 phút).',
                            style: TextStyle(
                              color: t.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _bankRow(AppTokens t, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: t.inkMuted,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    value,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: t.ink,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã copy: $value'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: Icon(Icons.copy, size: 16, color: t.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(
    AppTokens t, {
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      inputFormatters: formatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.line),
        ),
      ),
    );
  }

  Widget _methodTile(
    AppTokens t,
    PaymentMethod method, {
    IconData? icon,
    Color? iconColor,
    Widget? iconWidget,
    required String title,
    required String subtitle,
  }) {
    final selected = _method == method;
    return GestureDetector(
      onTap: () => setState(() => _method = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(t.cardRadius),
          border: Border.all(
            color: selected ? t.primary : t.line,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? null : t.cardShadow,
        ),
        child: Row(
          children: [
            if (iconWidget != null)
              iconWidget
            else
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (iconColor ?? t.primary).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: t.ink,
                    ),
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
                color: selected ? t.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? t.primary : t.inkMuted,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
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

  Widget _summaryRow(AppTokens t, String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: t.inkMuted,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: t.ink2,
          ),
        ),
      ],
    );
  }
}

// ============ Input formatters ============

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final s = buf.toString();
    return TextEditingValue(
      text: s,
      selection: TextSelection.collapsed(offset: s.length),
    );
  }
}

class _ExpFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    String s;
    if (digits.length >= 3) {
      s = '${digits.substring(0, 2)}/${digits.substring(2)}';
    } else {
      s = digits;
    }
    return TextEditingValue(
      text: s,
      selection: TextSelection.collapsed(offset: s.length),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
