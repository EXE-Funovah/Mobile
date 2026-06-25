import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/providers/user_profile_provider.dart';
import '../quiz/providers/documents_provider.dart';

/// Giới hạn số tài liệu cho gói Free (chưa trả phí).
/// Premium = KHÔNG giới hạn.
///
/// Lưu ý: đây là chặn phía UI cho trải nghiệm. Chốt chặn THẬT nằm ở backend
/// (`DocumentService` đọc `Plans:FreemiumActiveDocumentLimit`) — phải để khớp
/// cùng số này thì mới nhất quán.
const int kFreemiumDocLimit = 3;

/// User có đang là Premium không (mobile chỉ check tier; backend check thêm hạn).
bool isPremiumTier(String? tier) => (tier ?? '').toLowerCase() == 'premium';

/// Mở màn tải tài liệu. Nếu user Free đã đạt [kFreemiumDocLimit] tài liệu
/// → chặn và mời nâng cấp Premium thay vì mở upload.
Future<void> openUploadOrUpgrade(BuildContext context, WidgetRef ref) async {
  final user = ref.read(userProfileProvider).valueOrNull;
  final activeDocs = ref.read(documentsProvider).items.length;
  final premium = isPremiumTier(user?.subscriptionTier);

  if (!premium && activeDocs >= kFreemiumDocLimit) {
    final goPricing = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đã đạt giới hạn gói Free'),
        content: const Text(
          'Gói Free chỉ lưu tối đa $kFreemiumDocLimit tài liệu. '
          'Hãy xoá bớt tài liệu cũ, hoặc nâng cấp Premium để tải không giới hạn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Để sau'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Nâng cấp Premium'),
          ),
        ],
      ),
    );
    if (goPricing == true && context.mounted) {
      context.push('/student/pricing');
    }
    return;
  }

  if (context.mounted) context.push('/student/upload');
}
