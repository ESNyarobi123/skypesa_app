import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final int index;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.index = 0,
  });

  IconData _getIconForTask() {
    switch (task.icon) {
      case 'star':
        return Icons.star_rounded;
      case 'zap':
        return Icons.bolt_rounded;
      case 'play-circle':
        return Icons.play_circle_rounded;
      case 'external-link':
        return Icons.open_in_new_rounded;
      case 'eye':
        return Icons.visibility_rounded;
      case 'layout':
        return Icons.dashboard_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'compass':
        return Icons.explore_rounded;
      case 'mouse-pointer':
        return Icons.touch_app_rounded;
      case 'tv':
        return Icons.tv_rounded;
      default:
        return task.isFeatured ? Icons.star_rounded : Icons.play_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canComplete = task.canComplete && task.remaining > 0;

    return InkWell(
          onTap: canComplete ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Opacity(
            opacity: canComplete ? 1.0 : 0.5,
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              border: Border.all(
                color: task.isFeatured
                    ? AppColors.accent.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
              ),
              gradientColors: task.isFeatured
                  ? [
                      AppColors.accent.withOpacity(0.12),
                      AppColors.accent.withOpacity(0.04),
                    ]
                  : null,
              child: Row(
                children: [
                  // Task Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: task.isFeatured
                          ? AppColors.premiumGradient
                          : LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.3),
                                AppColors.primaryDark.withOpacity(0.2),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getIconForTask(),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Gap(14),

                  // Task Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (task.isFeatured)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.premiumGradient,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'HOT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Gap(6),
                        Row(
                          children: [
                            // Duration
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const Gap(4),
                            Text(
                              '${task.durationSeconds}s',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const Gap(12),

                            // Remaining
                            Icon(
                              Icons.repeat_rounded,
                              size: 14,
                              color: task.remaining > 0
                                  ? AppColors.primary
                                  : AppColors.error,
                            ),
                            const Gap(4),
                            Text(
                              '${task.remaining} left',
                              style: TextStyle(
                                color: task.remaining > 0
                                    ? AppColors.textSecondary
                                    : AppColors.error,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Reward
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '+TZS ${task.reward.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Gap(6),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: canComplete
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (50 * index).ms, duration: 400.ms)
        .slideX(begin: 0.05, end: 0);
  }
}
