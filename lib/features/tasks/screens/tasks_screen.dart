import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TaskProvider>().fetchTasks(filter: _filter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Enhanced Stats Header
            _buildEnhancedStatsHeader(provider),

            // Filter Tabs with better design
            _buildFilterTabs(),

            // Cooldown Timer Banner (shows when user must wait)
            if (provider.isOnCooldown) _buildCooldownBanner(provider),

            // Task List
            Expanded(child: _buildTaskList(provider)),
          ],
        );
      },
    );
  }

  Widget _buildCooldownBanner(TaskProvider provider) {
    return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning.withOpacity(0.15),
                AppColors.warning.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timer_rounded,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subiri Kidogo...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Task nyingine itapatikana baada ya sekunde ${provider.cooldownSeconds}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning,
                      AppColors.warning.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.cooldownSeconds}s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 1500.ms, color: AppColors.warning.withOpacity(0.3));
  }

  Widget _buildEnhancedStatsHeader(TaskProvider provider) {
    final progress = provider.dailyLimit > 0
        ? provider.completedToday / provider.dailyLimit
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Main Stats Card
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Daily Progress Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.trending_up_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const Gap(10),
                            const Text(
                              'Maendeleo Leo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        Text(
                          '${provider.completedToday} / ${provider.dailyLimit} Tasks',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    // Circular Progress
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 6,
                            backgroundColor: AppColors.surface,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress >= 1
                                  ? AppColors.accent
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            color: progress >= 1
                                ? AppColors.accent
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Gap(16),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        height: 8,
                        width:
                            MediaQuery.of(context).size.width * progress * 0.85,
                        decoration: BoxDecoration(
                          gradient: progress >= 1
                              ? AppColors.premiumGradient
                              : AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (progress >= 1
                                          ? AppColors.accent
                                          : AppColors.primary)
                                      .withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(16),
                const Divider(color: AppColors.surface, height: 1),
                const Gap(16),

                // Quick Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat(
                        icon: Icons.check_circle_rounded,
                        label: 'Zimekamilika',
                        value: '${provider.completedToday}',
                        color: AppColors.success,
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.surface),
                    Expanded(
                      child: _buildQuickStat(
                        icon: Icons.pending_rounded,
                        label: 'Zimebaki',
                        value: '${provider.remainingToday}',
                        color: AppColors.primary,
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.surface),
                    Expanded(
                      child: _buildQuickStat(
                        icon: Icons.monetization_on_rounded,
                        label: 'Kwa Task',
                        value:
                            'TZS ${provider.rewardPerTask.toStringAsFixed(0)}',
                        color: AppColors.accent,
                        isSmall: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isSmall = false,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const Gap(6),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmall ? 12 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(top: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(
            label: 'Zote',
            value: 'all',
            icon: Icons.grid_view_rounded,
            count: null,
          ),
          const Gap(10),
          _buildFilterChip(
            label: 'Featured',
            value: 'premium',
            icon: Icons.star_rounded,
            isPremium: true,
          ),
          const Gap(10),
          _buildFilterChip(
            label: 'Kawaida',
            value: 'free',
            icon: Icons.play_circle_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
    int? count,
    bool isPremium = false,
  }) {
    final isSelected = _filter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _filter = value;
        });
        context.read<TaskProvider>().fetchTasks(filter: value);
      },
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? (isPremium
                    ? AppColors.premiumGradient
                    : AppColors.primaryGradient)
              : null,
          color: isSelected ? null : AppColors.card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.surface,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isPremium ? AppColors.accent : AppColors.primary)
                        .withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (count != null) ...[
              const Gap(6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(TaskProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .rotate(begin: 0, end: 0.1, duration: 1.seconds),
            const Gap(20),
            const Text(
              'Inapakia tasks...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
              const Gap(20),
              const Text(
                'Imeshindikana kupakia',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              Text(
                'Tatizo la mtandao. Jaribu tena.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const Gap(24),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => provider.fetchTasks(filter: _filter),
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          Gap(8),
                          Text(
                            'Jaribu Tena',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.glassGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
              ),
              const Gap(24),
              const Text(
                'Hakuna tasks sasa hivi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              Text(
                'Rudi baadaye kuangalia tasks mpya',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const Gap(24),
              OutlinedButton.icon(
                onPressed: () => provider.fetchTasks(filter: _filter),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchTasks(filter: _filter),
      color: AppColors.primary,
      backgroundColor: AppColors.card,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: provider.tasks.length,
        itemBuilder: (context, index) {
          final task = provider.tasks[index];
          return TaskCard(
            task: task,
            index: index,
            onTap: () {
              if (provider.isOnCooldown) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Subiri sekunde ${provider.cooldownSeconds} kabla ya kuanza task nyingine.',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColors.warning,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                return;
              }

              if (task.canComplete && task.remaining > 0) {
                Navigator.pushNamed(
                  context,
                  '/task-execution',
                  arguments: task,
                ).then((result) {
                  // Refresh tasks after returning from task execution
                  if (result == true) {
                    provider.fetchTasks(filter: _filter);
                  }
                });
              }
            },
          );
        },
      ),
    );
  }
}
