import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          icon: Icons.rocket_launch_outlined,
          label: 'Upgrade',
          color: Colors.purple,
          onTap: () {},
        ),
        _buildActionItem(
          icon: Icons.task_alt,
          label: 'Tasks',
          color: AppColors.primary,
          onTap: () {},
        ),
        _buildActionItem(
          icon: Icons.people_outline,
          label: 'Team',
          color: Colors.blue,
          onTap: () {},
        ),
        _buildActionItem(
          icon: Icons.headset_mic_outlined,
          label: 'Support',
          color: Colors.orange,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          GlassContainer(
            width: 60,
            height: 60,
            borderRadius: 16,
            padding: const EdgeInsets.all(12),
            gradientColors: [color.withOpacity(0.2), color.withOpacity(0.05)],
            border: Border.all(color: color.withOpacity(0.3), width: 1),
            child: Icon(icon, color: color, size: 28),
          ),
          const Gap(8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
