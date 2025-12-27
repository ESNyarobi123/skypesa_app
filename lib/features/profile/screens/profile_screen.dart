import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<UserProvider>().changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully!')),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<UserProvider>().error ?? 'Failed to change password',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'My Account',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
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

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            child: Column(
              children: [
                // User Info Card
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
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(3),
                            child: CircleAvatar(
                              radius: 47,
                              backgroundColor: AppColors.card,
                              backgroundImage: user?.avatar != null
                                  ? NetworkImage(user!.avatar!)
                                  : null,
                              child: user?.avatar == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppColors.textSecondary,
                                    )
                                  : null,
                            ),
                          ),
                          const Gap(16),
                          Text(
                            user?.name ?? 'User Name',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            user?.email ?? 'email@example.com',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const Gap(12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient:
                                  user?.subscription?.planName?.toLowerCase() ==
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.workspace_premium_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  user?.subscription?.displayName ??
                                      'Free Plan',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/plans'),
                              icon: const Icon(Icons.upgrade_rounded, size: 18),
                              label: const Text('Upgrade Plan'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.accent,
                                side: BorderSide(
                                  color: AppColors.accent.withOpacity(0.5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.1, end: 0),

                const Gap(32),

                // Account Settings
                _buildSettingsSection(
                  title: 'Account Settings',
                  items: [
                    _SettingsItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      subtitle: 'Update your personal info',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Manage your alerts',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.security_rounded,
                      title: 'Security',
                      subtitle: 'Password & 2FA',
                      onTap: () {},
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                const Gap(24),

                // Change Password Section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Change Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Gap(16),
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Current Password',
                          hint: 'Enter current password',
                          controller: _currentPasswordController,
                          obscureText: true,
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.textSecondary,
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                        ),
                        const Gap(16),
                        CustomTextField(
                          label: 'New Password',
                          hint: 'Enter new password',
                          controller: _newPasswordController,
                          obscureText: true,
                          prefixIcon: const Icon(
                            Icons.lock_reset,
                            color: AppColors.textSecondary,
                          ),
                          validator: (value) =>
                              value!.length < 6 ? 'Min 6 chars' : null,
                        ),
                        const Gap(24),
                        Consumer<UserProvider>(
                          builder: (context, provider, child) {
                            return PrimaryButton(
                              text: 'Update Password',
                              isLoading: provider.isLoading,
                              onPressed: _handleChangePassword,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

                const Gap(32),

                // Support Button
                PrimaryButton(
                  text: 'Support & Help',
                  onPressed: () => Navigator.pushNamed(context, '/support'),
                  color: AppColors.info,
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

                const Gap(16),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surface),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.icon,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textTertiary,
                    ),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    Divider(height: 1, indent: 70, color: AppColors.surface),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
