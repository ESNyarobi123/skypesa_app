import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../services/support_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with SingleTickerProviderStateMixin {
  final _supportService = SupportService();
  late TabController _tabController;

  ContactInfo? _contactInfo;
  FAQData? _faqData;
  TicketStats? _stats;
  List<Ticket> _tickets = [];
  String _selectedCategory = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _supportService.getContactInfo(),
      _supportService.getFAQs(),
      _supportService.getStats(),
      _supportService.getTickets(),
    ]);

    if (mounted) {
      setState(() {
        _contactInfo = results[0] as ContactInfo?;
        _faqData = results[1] as FAQData?;
        _stats = results[2] as TicketStats?;
        _tickets = (results[3] as TicketListResult).tickets;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Msaada',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(icon: Icon(Icons.contact_support_rounded), text: 'Wasiliana'),
            Tab(icon: Icon(Icons.help_rounded), text: 'FAQ'),
            Tab(icon: Icon(Icons.confirmation_number_rounded), text: 'Tickets'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildContactTab(),
                _buildFAQTab(),
                _buildTicketsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTicketSheet(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Ombi Jipya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildHeroCard(),
          const Gap(24),
          _buildContactOptions(),
          const Gap(24),
          _buildSocialLinks(),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF536DFE), Color(0xFF448AFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.headset_mic_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const Gap(16),
          const Text(
            'Tunakusaidia 24/7',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(
            _contactInfo?.responseTime ?? 'Jibu ndani ya masaa 24-48',
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
          ),
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _contactInfo?.workingHours ?? 'Mon-Fri: 9AM-6PM',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildContactOptions() {
    return Column(
      children: [
        _buildContactCard(
          icon: Icons.chat_rounded,
          title: 'WhatsApp',
          subtitle: _contactInfo?.whatsapp ?? '+255 700 000 000',
          color: const Color(0xFF25D366),
          onTap: () => _launchUrl(
            'https://wa.me/${_contactInfo?.whatsapp?.replaceAll(RegExp(r'[^0-9]'), '') ?? "255700000000"}',
          ),
        ),
        const Gap(12),
        _buildContactCard(
          icon: Icons.email_rounded,
          title: 'Email',
          subtitle: _contactInfo?.email ?? 'support@skypesa.site',
          color: const Color(0xFFEA4335),
          onTap: () => _launchUrl(
            'mailto:${_contactInfo?.email ?? "support@skypesa.site"}',
          ),
        ),
        const Gap(12),
        _buildContactCard(
          icon: Icons.phone_rounded,
          title: 'Simu',
          subtitle: _contactInfo?.phone ?? '+255 700 000 000',
          color: const Color(0xFF448AFF),
          onTap: () =>
              _launchUrl('tel:${_contactInfo?.phone ?? "+255700000000"}'),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      subtitle,
                      style: TextStyle(color: color, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tufuate',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              Icons.telegram,
              const Color(0xFF0088CC),
              _contactInfo?.social.telegram,
            ),
            const Gap(16),
            _buildSocialButton(
              Icons.facebook,
              const Color(0xFF1877F2),
              _contactInfo?.social.facebook,
            ),
            const Gap(16),
            _buildSocialButton(
              Icons.camera_alt_rounded,
              const Color(0xFFE4405F),
              _contactInfo?.social.instagram,
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildSocialButton(IconData icon, Color color, String? url) {
    return InkWell(
      onTap: url != null ? () => _launchUrl(url) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildFAQTab() {
    if (_faqData == null)
      return const Center(
        child: Text('No FAQs', style: TextStyle(color: Colors.white)),
      );

    final filteredFaqs = _selectedCategory == 'all'
        ? _faqData!.faqs
        : _faqData!.faqs.where((f) => f.category == _selectedCategory).toList();

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _faqData!.categories.length,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (context, index) {
              final cat = _faqData!.categories[index];
              final isSelected = _selectedCategory == cat.id;
              return FilterChip(
                selected: isSelected,
                label: Text(cat.name),
                onSelected: (_) => setState(() => _selectedCategory = cat.id),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredFaqs.length,
            itemBuilder: (context, index) =>
                _buildFAQItem(filteredFaqs[index], index),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(FAQ faq, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surface),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textSecondary,
        title: Text(
          faq.question,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        children: [
          Text(
            faq.answer,
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (50 * index).ms);
  }

  Widget _buildTicketsTab() {
    return Column(
      children: [
        if (_stats != null) _buildStatsRow(),
        Expanded(
          child: _tickets.isEmpty
              ? _buildEmptyTickets()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tickets.length,
                  itemBuilder: (context, index) =>
                      _buildTicketCard(_tickets[index], index),
                ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Jumla', _stats!.total, const Color(0xFF7C4DFF)),
          _buildStat('Wazi', _stats!.open, AppColors.warning),
          _buildStat('Anaendelea', _stats!.inProgress, const Color(0xFF448AFF)),
          _buildStat('Imefungwa', _stats!.closed, AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 22,
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

  Widget _buildEmptyTickets() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const Gap(16),
          const Text(
            'Hakuna Tickets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(
            'Bofya "Ombi Jipya" kuanza',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket, int index) {
    final statusColor = _getStatusColor(ticket.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/ticket-detail',
          arguments: ticket.ticketNumber,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ticket.statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  ticket.ticketNumber,
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
              ],
            ),
            const Gap(12),
            Text(
              ticket.subject,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Gap(8),
            Row(
              children: [
                Icon(
                  Icons.category_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const Gap(4),
                Text(
                  ticket.categoryLabel,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (ticket.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${ticket.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (60 * index).ms);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return AppColors.warning;
      case 'in_progress':
        return const Color(0xFF448AFF);
      case 'resolved':
        return AppColors.success;
      case 'closed':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showCreateTicketSheet() {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    String category = 'general';
    String priority = 'medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const Gap(20),
                const Text(
                  'Ombi Jipya la Msaada',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(20),
                TextField(
                  controller: subjectController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mada',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const Gap(14),
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: AppColors.card,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Kategoria',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'general', child: Text('Jumla')),
                    DropdownMenuItem(value: 'task', child: Text('Task')),
                    DropdownMenuItem(
                      value: 'withdrawal',
                      child: Text('Kutoa Pesa'),
                    ),
                    DropdownMenuItem(
                      value: 'subscription',
                      child: Text('Subscription'),
                    ),
                    DropdownMenuItem(value: 'account', child: Text('Akaunti')),
                    DropdownMenuItem(value: 'bug', child: Text('Hitilafu')),
                  ],
                  onChanged: (v) => setSheetState(() => category = v!),
                ),
                const Gap(14),
                TextField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Maelezo',
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const Gap(20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (subjectController.text.isEmpty ||
                          messageController.text.isEmpty)
                        return;
                      final result = await _supportService.createTicket(
                        subject: subjectController.text,
                        category: category,
                        message: messageController.text,
                        priority: priority,
                      );
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.message),
                            backgroundColor: result.success
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        );
                        if (result.success) _loadData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Tuma Ombi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
