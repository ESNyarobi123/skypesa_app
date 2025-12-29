import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../services/notification_service.dart';

class AnnouncementDialog {
  static Future<void> showIfAvailable(BuildContext context) async {
    final service = NotificationService();
    final result = await service.getAnnouncements();

    if (result.popup.isNotEmpty && context.mounted) {
      for (final announcement in result.popup) {
        if (context.mounted) {
          await _showAnnouncementDialog(context, announcement, service);
        }
      }
    }
  }

  static Future<void> _showAnnouncementDialog(
    BuildContext context,
    Announcement announcement,
    NotificationService service,
  ) async {
    final color = _hexToColor(announcement.color);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.card, const Color(0xFF1A1A2E)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: -5,
              ),
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(27),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.7)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Icon(
                        _getIcon(announcement.icon),
                        color: Colors.white,
                        size: 36,
                      ),
                    ).animate().scale(
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    ),
                    const Gap(18),
                    Text(
                      announcement.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms),
                    const Gap(6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        announcement.typeLabel,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      announcement.bodyPreview,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms),
                    const Gap(20),
                    // Time info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const Gap(6),
                        Text(
                          announcement.createdAtHuman,
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms),
                    const Gap(24),
                    // Action button
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            await service.dismissAnnouncement(announcement.id);
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded, color: Colors.white),
                              Gap(8),
                              Text(
                                'Nimesoma',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                  ],
                ),
              ),
            ],
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
      ),
    );
  }

  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  static IconData _getIcon(String icon) {
    switch (icon) {
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'play-circle':
        return Icons.play_circle_rounded;
      case 'alert-triangle':
        return Icons.warning_amber_rounded;
      case 'info':
        return Icons.info_rounded;
      case 'check-circle':
        return Icons.check_circle_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'bell':
        return Icons.notifications_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }
}
