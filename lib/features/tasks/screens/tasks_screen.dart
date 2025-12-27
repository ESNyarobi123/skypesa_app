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
            // Stats Header
            _buildStatsHeader(provider),

            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip('All Tasks', 'all', Icons.list_rounded),
                  const Gap(10),
                  _buildFilterChip('Featured', 'premium', Icons.star_rounded),
                  const Gap(10),
                  _buildFilterChip(
                    'Regular',
                    'free',
                    Icons.play_circle_rounded,
                  ),
                ],
              ),
            ),

            // Task List
            Expanded(child: _buildTaskList(provider)),
          ],
        );
      },
    );
  }

  Widget _buildStatsHeader(TaskProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.check_circle_rounded,
                label: 'Completed',
                value: '${provider.completedToday}',
                color: AppColors.success,
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.surface),
            Expanded(
              child: _buildStatItem(
                icon: Icons.hourglass_empty_rounded,
                label: 'Remaining',
                value: '${provider.remainingToday}',
                color: AppColors.primary,
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.surface),
            Expanded(
              child: _buildStatItem(
                icon: Icons.monetization_on_rounded,
                label: 'Per Task',
                value: 'TZS ${provider.rewardPerTask.toStringAsFixed(0)}',
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const Gap(6),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _filter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _filter = value;
        });
        context.read<TaskProvider>().fetchTasks(filter: value);
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.card,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.surface,
          ),
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
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(TaskProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error.withOpacity(0.5),
            ),
            const Gap(16),
            Text(
              'Failed to load tasks',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const Gap(8),
            TextButton.icon(
              onPressed: () => provider.fetchTasks(filter: _filter),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: AppColors.textTertiary),
            const Gap(16),
            const Text(
              'No tasks available',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const Gap(8),
            Text(
              'Check back later for new tasks',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchTasks(filter: _filter),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
        itemCount: provider.tasks.length,
        itemBuilder: (context, index) {
          final task = provider.tasks[index];
          return TaskCard(
            task: task,
            index: index,
            onTap: () {
              if (task.canComplete && task.remaining > 0) {
                Navigator.pushNamed(
                  context,
                  '/task-execution',
                  arguments: task,
                );
              }
            },
          );
        },
      ),
    );
  }
}
