import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.dashboardData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: provider.fetchDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                _buildBalanceCard(provider),

                const Gap(24),

                // Quick Stats
                _buildQuickStats(provider),

                const Gap(24),

                // Daily Progress
                _buildDailyProgress(provider),

                const Gap(24),

                // Earnings Summary
                _buildEarningsSummary(provider),

                const Gap(24),

                // Quick Actions
                _buildQuickActions(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(DashboardProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wallet Balance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  provider.subscription.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            'TZS ${provider.walletBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: _buildBalanceAction(
                  icon: Icons.add_rounded,
                  label: 'Tasks',
                  onTap: () {},
                ),
              ),
              const Gap(12),
              Expanded(
                child: _buildBalanceAction(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Withdraw',
                  onTap: () => Navigator.pushNamed(context, '/withdraw'),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildBalanceAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const Gap(8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(DashboardProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.groups_rounded,
            label: 'Referrals',
            value: provider.referralCount.toString(),
            color: AppColors.info,
          ),
        ),
        const Gap(12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up_rounded,
            label: 'Per Task',
            value: 'TZS ${provider.rewardPerTask.toStringAsFixed(0)}',
            color: AppColors.success,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyProgress(DashboardProvider provider) {
    final progress = provider.tasksLimit > 0
        ? provider.tasksToday / provider.tasksLimit
        : 0.0;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.tasksRemaining} remaining',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${provider.tasksToday} / ${provider.tasksLimit} tasks',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 10,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildEarningsSummary(DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Earnings Summary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(16),
        Row(
          children: [
            Expanded(
              child: _buildEarningsCard(
                label: 'Today',
                amount: provider.todayEarnings,
                icon: Icons.today_rounded,
                color: AppColors.primary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _buildEarningsCard(
                label: 'This Week',
                amount: provider.weekEarnings,
                icon: Icons.date_range_rounded,
                color: AppColors.info,
              ),
            ),
          ],
        ),
        const Gap(12),
        _buildEarningsCard(
          label: 'This Month',
          amount: provider.monthEarnings,
          icon: Icons.calendar_month_rounded,
          color: AppColors.success,
          isLarge: true,
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildEarningsCard({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
    bool isLarge = false,
  }) {
    return GlassContainer(
      padding: EdgeInsets.all(isLarge ? 20 : 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isLarge ? 12 : 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isLarge ? 28 : 22),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isLarge ? 14 : 12,
                  ),
                ),
                const Gap(4),
                Text(
                  'TZS ${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isLarge ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textTertiary,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.workspace_premium_rounded,
                label: 'Upgrade',
                color: AppColors.accent,
                onTap: () => Navigator.pushNamed(context, '/plans'),
              ),
            ),
            const Gap(12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.share_rounded,
                label: 'Invite',
                color: AppColors.info,
                onTap: () {},
              ),
            ),
            const Gap(12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.headset_mic_rounded,
                label: 'Support',
                color: AppColors.success,
                onTap: () => Navigator.pushNamed(context, '/support'),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Gap(8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
