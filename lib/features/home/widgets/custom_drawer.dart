import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

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
            colors: [AppColors.background, AppColors.card.withOpacity(0.98)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with user info
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.primaryDark.withOpacity(0.05),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // My Account Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.account_circle_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'My Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
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
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user?.subscription?.displayName ?? 'Free',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),

              const SizedBox(height: 8),

              // Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Main Section
                    _SectionHeader(title: 'MAIN'),
                    _DrawerItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Edit Profile',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      },
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),

                    _DrawerItem(
                      icon: Icons.workspace_premium_rounded,
                      label: 'Subscription Plans',
                      subtitle: 'Upgrade for more earnings',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/plans');
                      },
                      isHighlighted: true,
                    ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.2),

                    const SizedBox(height: 16),

                    // Money Section
                    _SectionHeader(title: 'MONEY'),
                    _DrawerItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'My Wallet',
                      onTap: () {
                        Navigator.pop(context);
                        // Switch to wallet tab - for now just close
                      },
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),

                    _DrawerItem(
                      icon: Icons.payments_outlined,
                      label: 'Withdrawals',
                      subtitle: 'Request & track withdrawals',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/withdraw');
                      },
                    ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.2),

                    _DrawerItem(
                      icon: Icons.history_rounded,
                      label: 'Transaction History',
                      onTap: () {
                        Navigator.pop(context);
                        // Switch to wallet tab
                      },
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),

                    const SizedBox(height: 16),

                    // Social Section
                    _SectionHeader(title: 'SOCIAL'),
                    _DrawerItem(
                      icon: Icons.share_rounded,
                      label: 'Invite Friends',
                      subtitle: 'Earn bonuses for referrals',
                      onTap: () {
                        Navigator.pop(context);
                        // Switch to referrals tab
                      },
                    ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.2),

                    _DrawerItem(
                      icon: Icons.emoji_events_rounded,
                      label: 'Leaderboard',
                      onTap: () {
                        Navigator.pop(context);
                        // Switch to leaderboard tab
                      },
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),

                    const SizedBox(height: 16),

                    // Help Section
                    _SectionHeader(title: 'HELP'),
                    _DrawerItem(
                      icon: Icons.headset_mic_rounded,
                      label: 'Support Center',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/support');
                      },
                    ).animate().fadeIn(delay: 450.ms).slideX(begin: -0.2),

                    _DrawerItem(
                      icon: Icons.help_outline_rounded,
                      label: 'FAQ',
                      onTap: () {
                        Navigator.pop(context);
                        _showFAQDialog(context);
                      },
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),

                    _DrawerItem(
                      icon: Icons.info_outline_rounded,
                      label: 'About SKYpesa',
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutDialog(context);
                      },
                    ).animate().fadeIn(delay: 550.ms).slideX(begin: -0.2),
                  ],
                ),
              ),

              // Logout Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'SKYpesa',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Earn money by completing simple tasks! Watch ads, download apps, and get paid.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: AppColors.primary),
            SizedBox(width: 12),
            Text(
              'FAQ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
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
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isHighlighted;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isHighlighted = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            gradient: isHighlighted
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accent.withOpacity(0.15),
                      AppColors.accent.withOpacity(0.05),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(14),
            border: isHighlighted
                ? Border.all(color: AppColors.accent.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.error.withOpacity(0.1)
                      : isHighlighted
                      ? AppColors.accent.withOpacity(0.15)
                      : AppColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isDestructive
                      ? AppColors.error
                      : isHighlighted
                      ? AppColors.accent
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: isDestructive
                            ? AppColors.error
                            : isHighlighted
                            ? AppColors.accent
                            : Colors.white,
                        fontSize: 15,
                        fontWeight: isHighlighted
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: isHighlighted
                              ? AppColors.accent.withOpacity(0.7)
                              : AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDestructive
                    ? AppColors.error.withOpacity(0.5)
                    : AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
