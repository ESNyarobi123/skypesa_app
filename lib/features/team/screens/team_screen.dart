import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../providers/team_provider.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TeamProvider>().fetchReferralData();
    });
  }

  void _copyReferralLink(String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral link copied!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _shareReferral(TeamProvider provider) {
    final message = provider.shareMessage.isNotEmpty
        ? provider.shareMessage
        : 'Join SKYpesa and earn money! Use my referral code: ${provider.referralCode}. ${provider.referralLink}';

    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share message copied to clipboard!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.referralData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: provider.fetchReferralData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Referral Stats Card
                _buildReferralStatsCard(provider),

                const Gap(24),

                // Referral Code Section
                _buildReferralCodeSection(provider),

                const Gap(24),

                // Share Buttons
                _buildShareSection(provider),

                const Gap(24),

                // How It Works
                _buildHowItWorks(),

                const Gap(24),

                // Referral Users List
                if (provider.referralUsers.isNotEmpty)
                  _buildReferralUsersList(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReferralStatsCard(TeamProvider provider) {
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
        children: [
          const Icon(Icons.people_alt_rounded, color: Colors.white, size: 48),
          const Gap(12),
          const Text(
            'Invite Friends & Earn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          const Text(
            'Earn bonuses when friends join and complete tasks',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const Gap(24),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Total Referrals',
                  value: provider.totalReferrals.toString(),
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: _buildStatItem(
                  label: 'Active',
                  value: provider.activeReferrals.toString(),
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: _buildStatItem(
                  label: 'Earnings',
                  value: 'TZS ${provider.totalEarnings.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildStatItem({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildReferralCodeSection(TeamProvider provider) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Referral Code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    provider.referralCode,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _copyReferralLink(provider.referralCode),
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          const Text(
            'Referral Link',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    provider.referralLink,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => _copyReferralLink(provider.referralLink),
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildShareSection(TeamProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _shareReferral(provider),
            icon: const Icon(Icons.share_rounded),
            label: const Text('Share Link'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const Gap(12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surface),
          ),
          child: IconButton(
            onPressed: () => _copyReferralLink(provider.referralLink),
            icon: const Icon(Icons.link_rounded, color: AppColors.primary),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildHowItWorks() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How It Works',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          _buildStep(
            number: '1',
            title: 'Share Your Link',
            description: 'Send your referral link to friends',
            icon: Icons.share_rounded,
          ),
          const Gap(12),
          _buildStep(
            number: '2',
            title: 'Friends Sign Up',
            description: 'They register using your code',
            icon: Icons.person_add_rounded,
          ),
          const Gap(12),
          _buildStep(
            number: '3',
            title: 'Both Earn',
            description: 'Get bonus when they complete tasks',
            icon: Icons.monetization_on_rounded,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Icon(icon, color: AppColors.primary, size: 24),
      ],
    );
  }

  Widget _buildReferralUsersList(TeamProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Referrals (${provider.referralUsers.length})',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(16),
        ...provider.referralUsers.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surface),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  (user['name']?.toString() ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                user['name']?.toString() ?? 'User',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                user['joined_at']?.toString() ?? '',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: user['is_active'] == true
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.textTertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user['is_active'] == true ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: user['is_active'] == true
                        ? AppColors.success
                        : AppColors.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms);
        }),
      ],
    );
  }
}
