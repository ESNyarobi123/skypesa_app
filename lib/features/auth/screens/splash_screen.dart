import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation to finish (at least 3 seconds for branding)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check auth status
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuthStatus();

    if (!mounted) return;

    debugPrint('=== SPLASH SCREEN AUTH CHECK ===');
    debugPrint('isAuthenticated: ${authProvider.isAuthenticated}');
    debugPrint('isBlocked: ${authProvider.isBlocked}');
    debugPrint('blockedInfo: ${authProvider.blockedInfo}');
    debugPrint('blockedInfo.isBlocked: ${authProvider.blockedInfo?.isBlocked}');

    if (authProvider.isAuthenticated) {
      // Check if user is blocked
      if (authProvider.isBlocked && authProvider.blockedInfo != null) {
        debugPrint('>>> Navigating to BLOCKED screen');
        Navigator.pushReplacementNamed(
          context,
          '/blocked',
          arguments: authProvider.blockedInfo,
        );
      } else {
        debugPrint('>>> Navigating to DASHBOARD');
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } else {
      debugPrint('>>> Navigating to LOGIN');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            left: -100,
            child:
                Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 150,
                            spreadRadius: 50,
                          ),
                        ],
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      duration: 3000.ms,
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.2, 1.2),
                    ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Container
                GlassContainer(
                      width: 160,
                      height: 160,
                      borderRadius: 40,
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.easeOutBack)
                    .shimmer(
                      delay: 1000.ms,
                      duration: 1500.ms,
                      color: Colors.white.withOpacity(0.3),
                    ),

                const Gap(32),

                // App Name
                Text(
                      'SKYpesa',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 800.ms)
                    .slideY(begin: 0.2, end: 0),

                const Gap(8),

                // Tagline
                Text(
                      'Make Money Online',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 800.ms)
                    .slideY(begin: 0.2, end: 0),
              ],
            ),
          ),

          // Loading Indicator
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 1500.ms),
        ],
      ),
    );
  }
}
