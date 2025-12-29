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
    return Consumer<LeaderboardProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () =>
              provider.fetchLeaderboard(period: provider.currentPeriod),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
            child: Column(
              children: [
                // TOP 3 Winners Podium
                _buildTopWinnersPodium(provider),

                const Gap(20),

                // My Rank Card
                if (provider.myRank != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildMyRankCard(provider.myRank!),
                  ),

                const Gap(16),

                // Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.card,
                          AppColors.surface.withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.all(4),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: '🔥 Today'),
                        Tab(text: '📅 Weekly'),
                        Tab(text: '🏆 Monthly'),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                const Gap(20),

                // Leaderboard Content
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  )
                else if (provider.entries.isEmpty)
                  _buildEmptyState()
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Ranking header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.1),
                                AppColors.primaryDark.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.leaderboard_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const Gap(8),
                              const Text(
                                'All Rankings',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${provider.entries.length} users',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 350.ms),
                        const Gap(16),
                        // Ranking list
                        ...provider.entries
                            .skip(3)
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                              return _buildLeaderboardItem(
                                provider.entries[entry.key + 3],
                                entry.key,
                              );
                            }),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopWinnersPodium(LeaderboardProvider provider) {
    if (provider.isLoading || provider.entries.isEmpty) {
      return Container(
        height: 280,
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withOpacity(0.1), AppColors.background],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final top3 = provider.entries.take(3).toList();

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
            AppColors.card,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Crown and Title
          Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ).createShader(bounds),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Gap(8),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFE0E0E0)],
                    ).createShader(bounds),
                    child: const Text(
                      'Top Champions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.9, 0.9)),

          const Gap(24),

          // Podium
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place
              if (top3.length >= 2)
                _buildPodiumItem(
                  entry: top3[1],
                  rank: 2,
                  height: 100,
                  color: const Color(0xFFC0C0C0),
                  gradientColors: [
                    const Color(0xFFC0C0C0),
                    const Color(0xFF888888),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
              const Gap(8),
              // 1st place
              if (top3.isNotEmpty)
                _buildPodiumItem(
                  entry: top3[0],
                  rank: 1,
                  height: 130,
                  color: const Color(0xFFFFD700),
                  gradientColors: [
                    const Color(0xFFFFD700),
                    const Color(0xFFFFA500),
                  ],
                  isFirst: true,
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3),
              const Gap(8),
              // 3rd place
              if (top3.length >= 3)
                _buildPodiumItem(
                  entry: top3[2],
                  rank: 3,
                  height: 80,
                  color: const Color(0xFFCD7F32),
                  gradientColors: [
                    const Color(0xFFCD7F32),
                    const Color(0xFF8B4513),
                  ],
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.15);
  }

  Widget _buildPodiumItem({
    required LeaderboardEntry entry,
    required int rank,
    required double height,
    required Color color,
    required List<Color> gradientColors,
    bool isFirst = false,
  }) {
    return Column(
      children: [
        // Crown for 1st place
        if (isFirst)
          ShaderMask(
            shaderCallback: (bounds) =>
                LinearGradient(colors: gradientColors).createShader(bounds),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 32,
            ),
          ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0, 0)),
        const Gap(4),
        // Avatar
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: gradientColors),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: isFirst ? 32 : 26,
            backgroundColor: AppColors.card,
            child: Text(
              entry.user.name.isNotEmpty
                  ? entry.user.name[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: isFirst ? 24 : 20,
              ),
            ),
          ),
        ),
        const Gap(8),
        // Name
        SizedBox(
          width: 80,
          child: Text(
            entry.user.name.split(' ').first,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isFirst ? 14 : 12,
            ),
          ),
        ),
        const Gap(4),
        // Earnings
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            'TZS ${entry.totalEarnings.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        const Gap(8),
        // Podium stand
        Container(
          width: isFirst ? 85 : 70,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: gradientColors,
                  ).createShader(bounds),
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isFirst ? 28 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${entry.tasksCompleted} tasks',
                  style: TextStyle(color: color.withOpacity(0.8), fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyRankCard(MyRank myRank) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF7C4DFF).withOpacity(0.2),
            const Color(0xFF536DFE).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C4DFF).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                const Gap(4),
                Text(
                  '#${myRank.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Gap(18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Your Ranking',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: AppColors.success,
                            size: 12,
                          ),
                          const Gap(2),
                          Text(
                            'Active',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Row(
                  children: [
                    _buildRankStat(
                      icon: Icons.monetization_on_rounded,
                      value: 'TZS ${myRank.totalEarnings.toStringAsFixed(0)}',
                      color: AppColors.accent,
                    ),
                    const Gap(16),
                    _buildRankStat(
                      icon: Icons.task_alt_rounded,
                      value: '${myRank.tasksCompleted} tasks',
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1);
  }

  Widget _buildRankStat({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const Gap(4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.leaderboard_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
          ),
          const Gap(20),
          const Text(
            'No rankings yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(
            'Complete tasks to appear on the leaderboard!',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, int index) {
    final rank = entry.rank;
    final isEven = index % 2 == 0;

    return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isEven ? AppColors.card : AppColors.surface.withOpacity(0.5),
                AppColors.card.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surface, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Rank
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.2),
                            AppColors.primary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '#$rank',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const Gap(14),
                    // Avatar
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.surface,
                      child: Text(
                        entry.user.name.isNotEmpty
                            ? entry.user.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Gap(12),
                    // Name and tasks
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(2),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const Gap(4),
                              Text(
                                '${entry.tasksCompleted} tasks',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Earnings
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.success.withOpacity(0.15),
                            AppColors.success.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        'TZS ${entry.totalEarnings.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (50 * index).ms, duration: 400.ms)
        .slideX(begin: 0.05, end: 0);
  }
}
