import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
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
      case 'video':
        return Icons.videocam_rounded;
      case 'ad':
        return Icons.campaign_rounded;
      default:
        return task.isFeatured ? Icons.star_rounded : Icons.play_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canComplete = task.canComplete && task.remaining > 0;

    return InkWell(
          onTap: canComplete ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: canComplete ? 1.0 : 0.5,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: task.isFeatured
                      ? [
                          AppColors.accent.withOpacity(0.15),
                          AppColors.accent.withOpacity(0.05),
                        ]
                      : [AppColors.card, AppColors.surface.withOpacity(0.5)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: task.isFeatured
                      ? AppColors.accent.withOpacity(0.4)
                      : AppColors.surface,
                  width: task.isFeatured ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: task.isFeatured
                        ? AppColors.accent.withOpacity(0.15)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Task Icon with gradient background
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: task.isFeatured
                            ? AppColors.premiumGradient
                            : AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (task.isFeatured
                                        ? AppColors.accent
                                        : AppColors.primary)
                                    .withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getIconForTask(),
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const Gap(14),

                    // Task Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Row with badges
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (task.isFeatured)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.premiumGradient,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent.withOpacity(
                                          0.4,
                                        ),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.local_fire_department_rounded,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      Gap(4),
                                      Text(
                                        'HOT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const Gap(8),

                          // Description if available
                          if (task.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                task.description,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                          // Stats Row
                          Row(
                            children: [
                              // Duration
                              _buildStatBadge(
                                icon: Icons.timer_outlined,
                                label: '${task.durationSeconds}s',
                                color: AppColors.info,
                              ),
                              const Gap(10),

                              // Remaining
                              _buildStatBadge(
                                icon: Icons.repeat_rounded,
                                label: '${task.remaining} imebaki',
                                color: task.remaining > 0
                                    ? AppColors.primary
                                    : AppColors.error,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Gap(12),

                    // Reward & Action
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Reward Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.success.withOpacity(0.2),
                                AppColors.success.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '+TZS',
                                style: TextStyle(
                                  color: AppColors.success.withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                task.reward.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(8),

                        // Action indicator
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: canComplete
                                ? AppColors.primary.withOpacity(0.15)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            canComplete
                                ? Icons.arrow_forward_rounded
                                : Icons.lock_rounded,
                            color: canComplete
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (50 * index).ms, duration: 400.ms)
        .slideX(begin: 0.05, end: 0);
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const Gap(4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
