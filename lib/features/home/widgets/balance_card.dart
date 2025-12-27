import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final String currency;

  const BalanceCard({super.key, required this.balance, this.currency = 'Tsh'});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      gradientColors: [
        AppColors.primary.withOpacity(0.15),
        AppColors.background.withOpacity(0.4),
      ],
      border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, color: AppColors.accent, size: 16),
                    Gap(4),
                    Text(
                      '+2.5%',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            '$currency ${balance.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const Gap(24),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.add,
                  label: 'Deposit',
                  onTap: () {},
                ),
              ),
              const Gap(16),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.arrow_outward,
                  label: 'Withdraw',
                  isPrimary: true,
                  onTap: () {
                    Navigator.pushNamed(context, '/withdraw');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.primaryGradient : null,
          color: isPrimary ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.white : AppColors.textPrimary,
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
