import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
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
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const Gap(10),
            const Text('Copied to clipboard!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _shareReferral(TeamProvider provider) {
    final message = provider.shareMessage.isNotEmpty
        ? provider.shareMessage
        : 'Join SKYpesa and earn money! Use my referral code: ${provider.referralCode}. ${provider.referralLink}';

    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.share_rounded, color: Colors.white),
            const Gap(10),
            const Text('Share message copied!'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                // Hero Card with Stats
                _buildHeroCard(provider),

                const Gap(24),

                // Stats Cards Row
                _buildStatsRow(provider),

                const Gap(24),

                // Referral Code Section
                _buildReferralCodeSection(provider),

                const Gap(24),

                // Share Buttons
                _buildShareSection(provider),

                const Gap(28),

                // How It Works
                _buildHowItWorks(),

                const Gap(28),

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

  Widget _buildHeroCard(TeamProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Gradient background
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE91E63),
                    Color(0xFFAD1457),
                    Color(0xFF7C4DFF),
                  ],
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Icon and Title
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const Gap(16),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFFFE0E8)],
                    ).createShader(bounds),
                    child: const Text(
                      'Invite & Earn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Earn bonuses when friends join and complete tasks',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(24),
                  // Mini Stats
                  Row(
                    children: [
                      _buildMiniStat(
                        '${provider.totalReferrals}',
                        'Total',
                        Icons.group_add_rounded,
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      _buildMiniStat(
                        '${provider.activeReferrals}',
                        'Active',
                        Icons.verified_rounded,
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      _buildMiniStat(
                        'TZS ${provider.totalEarnings.toStringAsFixed(0)}',
                        'Earned',
                        Icons.monetization_on_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1);
  }

  Widget _buildMiniStat(String value, String label, IconData icon) {
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const Gap(4),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const Gap(4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(TeamProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.currency_exchange_rounded,
            label: 'Bonus Per Referral',
            value: 'TZS 500',
            color: const Color(0xFF00E676),
          ),
        ),
        const Gap(12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.timeline_rounded,
            label: 'Conversion Rate',
            value: provider.totalReferrals > 0
                ? '${((provider.activeReferrals / provider.totalReferrals) * 100).toStringAsFixed(0)}%'
                : '0%',
            color: const Color(0xFF448AFF),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Gap(14),
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
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeSection(TeamProvider provider) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.card, const Color(0xFF1A1A2E)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Gap(12),
              const Text(
                'Your Referral Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(18),
          // Referral Code Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: Text(
                      provider.referralCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _copyReferralLink(provider.referralCode),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.copy_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(18),
          // Referral Link
          Row(
            children: [
              Icon(
                Icons.link_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
              const Gap(8),
              const Text(
                'Referral Link',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Gap(10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    provider.referralLink,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Gap(10),
                InkWell(
                  onTap: () => _copyReferralLink(provider.referralLink),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.copy_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildShareSection(TeamProvider provider) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE91E63).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _shareReferral(provider),
              icon: const Icon(Icons.share_rounded, size: 22),
              label: const Text(
                'Share & Invite',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        const Gap(12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surface),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _copyReferralLink(provider.referralLink),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Icon(
                  Icons.link_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        const Gap(12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surface),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Icon(
                  Icons.qr_code_rounded,
                  color: Color(0xFF7C4DFF),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildHowItWorks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const Gap(12),
            const Text(
              'How It Works',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Gap(20),
        _buildStep(
          number: '1',
          title: 'Share Your Link',
          description: 'Send your referral link to friends',
          icon: Icons.share_rounded,
          color: const Color(0xFFE91E63),
        ),
        const Gap(14),
        _buildStep(
          number: '2',
          title: 'Friends Sign Up',
          description: 'They register using your referral code',
          icon: Icons.person_add_rounded,
          color: const Color(0xFF448AFF),
        ),
        const Gap(14),
        _buildStep(
          number: '3',
          title: 'Both Earn Rewards',
          description: 'Get bonus when they complete 15 tasks',
          icon: Icons.celebration_rounded,
          color: const Color(0xFFFFD700),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.03)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralUsersList(TeamProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00BCD4), Color(0xFF00ACC1)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.group_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const Gap(12),
            Text(
              'Your Referrals (${provider.referralUsers.length})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Gap(18),
        ...provider.referralUsers.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.card, AppColors.surface.withOpacity(0.5)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.surface),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: user['is_active'] == true
                          ? [
                              AppColors.success,
                              AppColors.success.withOpacity(0.7),
                            ]
                          : [
                              AppColors.textTertiary,
                              AppColors.textTertiary.withOpacity(0.7),
                            ],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.card,
                    child: Text(
                      (user['name']?.toString() ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        color: user['is_active'] == true
                            ? AppColors.success
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name']?.toString() ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const Gap(4),
                          Flexible(
                            child: Text(
                              user['joined_at']?.toString() ?? '',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: user['is_active'] == true
                          ? [
                              AppColors.success.withOpacity(0.15),
                              AppColors.success.withOpacity(0.05),
                            ]
                          : [
                              AppColors.textTertiary.withOpacity(0.15),
                              AppColors.textTertiary.withOpacity(0.05),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: user['is_active'] == true
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.textTertiary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user['is_active'] == true
                            ? Icons.check_circle_rounded
                            : Icons.pending_rounded,
                        size: 14,
                        color: user['is_active'] == true
                            ? AppColors.success
                            : AppColors.textTertiary,
                      ),
                      const Gap(4),
                      Text(
                        user['is_active'] == true ? 'Active' : 'Pending',
                        style: TextStyle(
                          color: user['is_active'] == true
                              ? AppColors.success
                              : AppColors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (80 * index).ms, duration: 400.ms);
        }),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }
}
