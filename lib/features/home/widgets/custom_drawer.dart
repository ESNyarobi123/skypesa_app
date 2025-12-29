import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    Navigator.pop(context); // Close drawer first
    await context.read<AuthProvider>().logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0A0F),
              const Color(0xFF121218),
              AppColors.card.withOpacity(0.98),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.primary.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.08),
                      AppColors.accent.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header with user info - Premium design
                  Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1A237E).withOpacity(0.6),
                              const Color(0xFF00695C).withOpacity(0.4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Close button and badge row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.4,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.menu_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Menu',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // User avatar and info
                            Row(
                              children: [
                                // Premium avatar with glow effect
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.primaryGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.5,
                                        ),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 32,
                                    backgroundColor: AppColors.card,
                                    backgroundImage: user?.avatar != null
                                        ? NetworkImage(user!.avatar!)
                                        : null,
                                    child: user?.avatar == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 32,
                                            color: AppColors.textSecondary,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?.name ?? 'User',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user?.email ?? '',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      // Subscription badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient:
                                              user?.subscription?.planName
                                                          ?.toLowerCase() ==
                                                      'vip' ||
                                                  user?.subscription?.planName
                                                          ?.toLowerCase() ==
                                                      'gold' ||
                                                  user?.subscription?.planName
                                                          ?.toLowerCase() ==
                                                      'silver'
                                              ? AppColors.premiumGradient
                                              : AppColors.primaryGradient,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.workspace_premium_rounded,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                user
                                                        ?.subscription
                                                        ?.displayName ??
                                                    'Free',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.2, end: 0),

                  // Navigation Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      children: [
                        // Main Section
                        _SectionHeader(
                          title: 'ACCOUNT',
                        ).animate().fadeIn(delay: 100.ms),
                        _ModernDrawerItem(
                          icon: Icons.person_outline_rounded,
                          label: 'My Profile',
                          subtitle: 'View & edit your info',
                          color: const Color(0xFF7C4DFF),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/profile');
                          },
                        ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.15),

                        _ModernDrawerItem(
                          icon: Icons.workspace_premium_rounded,
                          label: 'Subscription Plans',
                          subtitle: 'Upgrade for more earnings',
                          color: const Color(0xFFFFD700),
                          isHighlighted: true,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/plans');
                          },
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.15),

                        const SizedBox(height: 12),

                        // Money Section
                        _SectionHeader(
                          title: 'FINANCES',
                        ).animate().fadeIn(delay: 250.ms),
                        _ModernDrawerItem(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'My Wallet',
                          subtitle: 'View balance & earnings',
                          color: const Color(0xFF00E676),
                          onTap: () {
                            Navigator.pop(context);
                            // This would switch to wallet tab
                          },
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.15),

                        _ModernDrawerItem(
                          icon: Icons.payments_rounded,
                          label: 'Withdraw Funds',
                          subtitle: 'Cash out your earnings',
                          color: const Color(0xFF448AFF),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/withdraw');
                          },
                        ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.15),

                        _ModernDrawerItem(
                          icon: Icons.history_rounded,
                          label: 'Transaction History',
                          subtitle: 'View all transactions',
                          color: const Color(0xFF00BCD4),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.15),

                        const SizedBox(height: 12),

                        // Social Section
                        _SectionHeader(
                          title: 'EARN MORE',
                        ).animate().fadeIn(delay: 450.ms),
                        _ModernDrawerItem(
                          icon: Icons.share_rounded,
                          label: 'Invite Friends',
                          subtitle: 'Earn bonuses for referrals',
                          color: const Color(0xFFE91E63),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.15),

                        _ModernDrawerItem(
                          icon: Icons.emoji_events_rounded,
                          label: 'Leaderboard',
                          subtitle: 'See top earners',
                          color: const Color(0xFFFFA726),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ).animate().fadeIn(delay: 550.ms).slideX(begin: -0.15),

                        const SizedBox(height: 12),

                        // Help Section
                        _SectionHeader(
                          title: 'SUPPORT',
                        ).animate().fadeIn(delay: 600.ms),
                        _ModernDrawerItem(
                          icon: Icons.headset_mic_rounded,
                          label: 'Help Center',
                          subtitle: 'Get support',
                          color: const Color(0xFF26A69A),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/support');
                          },
                        ).animate().fadeIn(delay: 650.ms).slideX(begin: -0.15),

                        _ModernDrawerItem(
                          icon: Icons.help_outline_rounded,
                          label: 'FAQ',
                          subtitle: 'Common questions',
                          color: const Color(0xFF78909C),
                          onTap: () {
                            Navigator.pop(context);
                            _showFAQDialog(context);
                          },
                        ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.15),

                        _ModernDrawerItem(
                          icon: Icons.info_outline_rounded,
                          label: 'About SKYpesa',
                          subtitle: 'App information',
                          color: const Color(0xFF9575CD),
                          onTap: () {
                            Navigator.pop(context);
                            _showAboutDialog(context);
                          },
                        ).animate().fadeIn(delay: 750.ms).slideX(begin: -0.15),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Logout Button - Premium Design
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.error.withOpacity(0.15),
                            AppColors.error.withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showLogoutConfirmation(context),
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.logout_rounded,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
                  ),

                  // App version removed as requested
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'SKYpesa',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Earn money by completing simple tasks! Watch ads, download apps, and get paid instantly.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF448AFF), const Color(0xFF2962FF)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'FAQ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _faqItem(
                'How do I earn money?',
                'Complete tasks like watching ads and downloading apps.',
              ),
              _faqItem(
                'When can I withdraw?',
                'You can withdraw once you reach the minimum amount for your plan.',
              ),
              _faqItem(
                'How long do withdrawals take?',
                'Withdrawals are processed within 24-48 hours.',
              ),
              _faqItem(
                'What are subscription plans?',
                'Premium plans give you more tasks and higher earnings per task.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.error, AppColors.error.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout? You will need to login again to access your account.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  Navigator.pop(dialogContext); // Close dialog
                  await _handleLogout(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 16, 6, 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _ModernDrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.subtitle,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            gradient: isHighlighted
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.2), color.withOpacity(0.08)],
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            border: isHighlighted
                ? Border.all(color: color.withOpacity(0.4), width: 1)
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.25), color.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: isHighlighted ? color : Colors.white,
                        fontSize: 15,
                        fontWeight: isHighlighted
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: isHighlighted
                              ? color.withOpacity(0.7)
                              : AppColors.textTertiary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (isHighlighted ? color : AppColors.surface)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isHighlighted ? color : AppColors.textTertiary,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
