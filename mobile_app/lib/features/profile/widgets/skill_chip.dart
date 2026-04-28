import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SkillChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;

  const SkillChip({super.key, required this.label, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.accentBlue.withOpacity(0.3),
      deleteIcon: onDeleted != null ? const Icon(Icons.close, size: 18, color: AppColors.primaryNavy) : null,
      onDeleted: onDeleted,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
    );
  }
}
