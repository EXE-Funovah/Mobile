import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class OrDivider extends StatelessWidget {
  final String label;
  const OrDivider({super.key, this.label = 'hoặc'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.inkMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
