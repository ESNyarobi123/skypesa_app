import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../leaderboard/screens/leaderboard_screen.dart';
import '../../tasks/screens/tasks_screen.dart';
import '../../team/screens/team_screen.dart';
import '../../wallet/screens/wallet_screen.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/modern_bottom_nav.dart';
import 'dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TasksScreen(),
    const WalletScreen(),
    const TeamScreen(),
    const LeaderboardScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Available Tasks',
    'My Wallet',
    'Referrals',
    'Leaderboard',
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawer: const CustomDrawer(),
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              backgroundColor: AppColors.background.withOpacity(0.95),
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: Text(
                _titles[_currentIndex],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              actions: [
                // My Account Button
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.card,
                            backgroundImage: user?.avatar != null
                                ? NetworkImage(user!.avatar!)
                                : null,
                            child: user?.avatar == null
                                ? const Icon(
                                    Icons.person,
                                    color: AppColors.textSecondary,
                                    size: 16,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      body: Stack(
        children: [
          // Background gradient orbs
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
          Positioned(
            bottom: 100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
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

          // Dashboard with custom header
          if (_currentIndex == 0)
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Custom Dashboard Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Menu Button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary.withOpacity(0.2),
                                  AppColors.primaryDark.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.menu_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openDrawer(),
                        ),

                        // Greeting and Name
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  user?.name ?? 'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // My Account Button
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                          child: Container(
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
                              radius: 22,
                              backgroundColor: AppColors.card,
                              backgroundImage: user?.avatar != null
                                  ? NetworkImage(user!.avatar!)
                                  : null,
                              child: user?.avatar == null
                                  ? const Icon(
                                      Icons.person,
                                      color: AppColors.textSecondary,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),
                  ),

                  // Dashboard Content
                  Expanded(child: _screens[0]),
                ],
              ),
            ),

          // Other screens
          if (_currentIndex != 0)
            SafeArea(
              bottom: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_currentIndex),
                  child: _screens[_currentIndex],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: ModernBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }
}
