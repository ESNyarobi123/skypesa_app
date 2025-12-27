import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../providers/leaderboard_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Fetch initial data
    Future.microtask(() {
      context.read<LeaderboardProvider>().fetchLeaderboard(period: 'weekly');
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final periods = ['daily', 'weekly', 'monthly'];
      context.read<LeaderboardProvider>().fetchLeaderboard(
        period: periods[_tabController.index],
      );
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // My Rank Card
        Consumer<LeaderboardProvider>(
          builder: (context, provider, child) {
            if (provider.myRank != null) {
              return _buildMyRankCard(provider.myRank!);
            }
            return const SizedBox.shrink();
          },
        ),

        // Tab Bar
        Container(
          margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surface, width: 1),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Today'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
        ),

        const Gap(16),

        // Leaderboard Content
        Expanded(
          child: Consumer<LeaderboardProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.entries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.leaderboard_outlined,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const Gap(16),
                      const Text(
                        'No rankings yet',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    provider.fetchLeaderboard(period: provider.currentPeriod),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  itemCount: provider.entries.length,
                  itemBuilder: (context, index) {
                    return _buildLeaderboardItem(
                      provider.entries[index],
                      index,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyRankCard(MyRank myRank) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primaryDark.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '#${myRank.rank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Ranking',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const Gap(4),
                Text(
                  'TZS ${myRank.totalEarnings.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${myRank.tasksCompleted}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Text(
                'tasks',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, int index) {
    final rank = entry.rank;

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: rank <= 3
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: rank == 1
                        ? [
                            const Color(0xFFFFD700).withOpacity(0.15),
                            const Color(0xFFFFA000).withOpacity(0.05),
                          ]
                        : rank == 2
                        ? [
                            const Color(0xFFC0C0C0).withOpacity(0.15),
                            const Color(0xFF9E9E9E).withOpacity(0.05),
                          ]
                        : [
                            const Color(0xFFCD7F32).withOpacity(0.15),
                            const Color(0xFFA0522D).withOpacity(0.05),
                          ],
                  )
                : null,
            color: rank > 3 ? AppColors.card : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: rank == 1
                  ? const Color(0xFFFFD700).withOpacity(0.3)
                  : rank == 2
                  ? const Color(0xFFC0C0C0).withOpacity(0.3)
                  : rank == 3
                  ? const Color(0xFFCD7F32).withOpacity(0.3)
                  : AppColors.surface,
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: rank == 1
                    ? const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                      )
                    : rank == 2
                    ? const LinearGradient(
                        colors: [Color(0xFFC0C0C0), Color(0xFF9E9E9E)],
                      )
                    : rank == 3
                    ? const LinearGradient(
                        colors: [Color(0xFFCD7F32), Color(0xFFA0522D)],
                      )
                    : null,
                color: rank > 3 ? AppColors.surface : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: rank <= 3
                    ? const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 24,
                      )
                    : Text(
                        '#$rank',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            title: Text(
              entry.user.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${entry.tasksCompleted} tasks completed',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'TZS ${entry.totalEarnings.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: rank <= 3 ? AppColors.accent : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Gap(2),
                Text(
                  'Earned',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (50 * index).ms, duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
  }
}
