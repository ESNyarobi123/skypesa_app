import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse(
      'https://wa.me/255655555555',
    ); // Replace with actual number
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchTicketSystem() async {
    // Navigate to ticket creation screen or open webview
    // For now, let's assume it's a webview or a new screen
    // Navigator.pushNamed(context, '/create-ticket');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support & Help')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            const Text(
              'How can we help you today?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            const Text(
              'Choose a support channel below',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const Gap(48),

            // Support Options
            _buildSupportOption(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'Live Chat Support',
              description: 'Chat with our support team directly via WhatsApp.',
              buttonText: 'Open WhatsApp',
              onTap: _launchWhatsApp,
              color: const Color(0xFF25D366), // WhatsApp Green
            ),
            const Gap(24),
            _buildSupportOption(
              context,
              icon: Icons.confirmation_number_outlined,
              title: 'Submit a Ticket',
              description: 'Create a support ticket for detailed inquiries.',
              buttonText: 'Create Ticket',
              onTap: _launchTicketSystem,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const Gap(16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Gap(24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
