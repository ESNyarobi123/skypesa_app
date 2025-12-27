import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../models/plan_model.dart';

class PlanCard extends StatelessWidget {
  final Plan plan;
  final bool isCurrent;
  final VoidCallback onSubscribe;
  final int index;

  const PlanCard({
    super.key,
    required this.plan,
    this.isCurrent = false,
    required this.onSubscribe,
    this.index = 0,
  });

  Color _getPlanColor() {
    switch (plan.name.toLowerCase()) {
      case 'vip':
        return const Color(0xFFFFD700); // Gold
      case 'gold':
        return const Color(0xFFFFB800);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'starter':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final planColor = _getPlanColor();
    final isPremiumPlan = plan.isPremium;

    return GlassContainer(
          width: 280,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(right: 16),
          border: Border.all(
            color: isPremiumPlan
                ? planColor.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: isPremiumPlan ? 2 : 1,
          ),
          gradientColors: isPremiumPlan
              ? [planColor.withOpacity(0.15), planColor.withOpacity(0.05)]
              : null,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: isPremiumPlan
                            ? LinearGradient(
                                colors: [planColor, planColor.withOpacity(0.7)],
                              )
                            : null,
                        color: isPremiumPlan ? null : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        plan.displayName.toUpperCase(),
                        style: TextStyle(
                          color: isPremiumPlan ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 14,
                            ),
                            Gap(4),
                            Text(
                              'Current',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const Gap(16),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TZS',
                      style: TextStyle(
                        color: isPremiumPlan ? planColor : Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      plan.price.toStringAsFixed(0),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        plan.durationDays != null
                            ? '/${plan.durationDays} days'
                            : '',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const Gap(8),

                // Description
                Text(
                  plan.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Gap(16),

                // Key Features
                _buildFeatureRow(
                  Icons.task_alt_rounded,
                  '${plan.dailyTaskLimit} tasks/day',
                  isPremiumPlan ? planColor : AppColors.primary,
                ),
                const Gap(10),
                _buildFeatureRow(
                  Icons.monetization_on_rounded,
                  'TZS ${plan.rewardPerTask.toStringAsFixed(0)}/task',
                  AppColors.success,
                ),
                const Gap(10),
                _buildFeatureRow(
                  Icons.percent_rounded,
                  '${plan.withdrawalFeePercent.toStringAsFixed(0)}% fee',
                  AppColors.info,
                ),
                const Gap(10),
                _buildFeatureRow(
                  Icons.account_balance_rounded,
                  'Min TZS ${plan.minWithdrawal.toStringAsFixed(0)}',
                  AppColors.warning,
                ),

                const Gap(20),

                // Subscribe Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrent ? null : onSubscribe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrent
                          ? AppColors.surface
                          : (isPremiumPlan ? planColor : AppColors.primary),
                      foregroundColor: isCurrent
                          ? AppColors.textSecondary
                          : (isPremiumPlan ? Colors.black : Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: isPremiumPlan ? 4 : 0,
                    ),
                    child: Text(
                      isCurrent
                          ? 'Current Plan'
                          : (plan.price == 0 ? 'Free Plan' : 'Upgrade Now'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (100 * index).ms, duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildFeatureRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const Gap(10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
