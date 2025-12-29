import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../services/plan_service.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final _planService = PlanService();

  List<Plan> _plans = [];
  CurrentSubscription? _subscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _planService.getPlans(),
      _planService.getCurrentSubscription(),
    ]);

    if (mounted) {
      setState(() {
        _plans = results[0] as List<Plan>;
        _subscription = results[1] as CurrentSubscription?;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(child: _buildCurrentPlan()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.dashboard_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const Gap(12),
                        const Text(
                          'Mipango Yote',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildPlanCard(_plans[index], index),
                      childCount: _plans.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C4DFF), Color(0xFF536DFE), Color(0xFF448AFF)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Gap(40),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const Gap(12),
                    const Text(
                      'Chagua Mpango',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pata zaidi kwa kupandisha',
                      style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildCurrentPlan() {
    final sub = _subscription?.data;
    final isActive = sub?.isActive == true;
    final planName = sub?.plan.displayName ?? 'Free';

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [
                  const Color(0xFF00E676).withOpacity(0.15),
                  const Color(0xFF00E676).withOpacity(0.05),
                ]
              : [AppColors.card, AppColors.surface.withOpacity(0.5)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive
              ? const Color(0xFF00E676).withOpacity(0.3)
              : AppColors.surface,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: _getPlanGradient(planName.toLowerCase()),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _getPlanColor(planName.toLowerCase()).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _getPlanIcon(planName.toLowerCase()),
              color: Colors.white,
              size: 28,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Mpango: ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      planName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                if (sub != null) ...[
                  const Gap(6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF00E676).withOpacity(0.15)
                              : AppColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sub.statusLabel,
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF00E676)
                                : AppColors.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (sub.daysRemaining > 0) ...[
                        const Gap(8),
                        Text(
                          'Siku ${sub.daysRemaining} zimebaki',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ] else ...[
                  const Gap(4),
                  Text(
                    'Huna subscription',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (sub?.isExpiringSoon == true)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 20,
              ),
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildPlanCard(Plan plan, int index) {
    final isCurrentPlan =
        _subscription?.data?.plan.slug == plan.slug ||
        (_subscription?.hasSubscription == false && plan.isFree);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.card, AppColors.surface.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: plan.isFeatured
              ? _getPlanColor(plan.slug).withOpacity(0.5)
              : AppColors.surface,
          width: plan.isFeatured ? 2 : 1,
        ),
        boxShadow: plan.isFeatured
            ? [
                BoxShadow(
                  color: _getPlanColor(plan.slug).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: _getPlanGradient(plan.slug),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(23),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getPlanIcon(plan.slug),
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (plan.isFeatured) ...[
                            const Gap(8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '⭐ POPULAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        plan.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Price
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.priceFormatted,
                      style: TextStyle(
                        color: _getPlanColor(plan.slug),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!plan.isFree && plan.durationDays != null)
                      Text(
                        ' /siku ${plan.durationDays}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                const Gap(20),
                // Stats Row
                Row(
                  children: [
                    _buildStatItem(
                      Icons.task_alt_rounded,
                      '${plan.dailyTaskLimit}/siku',
                      'Tasks',
                      const Color(0xFF00E676),
                    ),
                    _buildStatItem(
                      Icons.attach_money_rounded,
                      plan.rewardPerTaskFormatted,
                      'Kwa Task',
                      const Color(0xFFFFD700),
                    ),
                    _buildStatItem(
                      Icons.trending_up_rounded,
                      'TZS ${plan.monthlyEarningsEstimate.toStringAsFixed(0)}',
                      'Kwa Mwezi',
                      const Color(0xFF7C4DFF),
                    ),
                  ],
                ),
                const Gap(20),
                // Features
                ...plan.features
                    .take(4)
                    .map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF00E676,
                                ).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Color(0xFF00E676),
                                size: 14,
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              child: Text(
                                f,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                const Gap(16),
                // Button
                SizedBox(
                  width: double.infinity,
                  child: isCurrentPlan
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF00E676).withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF00E676),
                                size: 20,
                              ),
                              Gap(8),
                              Text(
                                'Mpango Wako',
                                style: TextStyle(
                                  color: Color(0xFF00E676),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: _getPlanGradient(plan.slug),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _getPlanColor(
                                  plan.slug,
                                ).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => _showPaymentSheet(plan),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              plan.isFree ? 'Chagua Bure' : 'Panda Sasa',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1);
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const Gap(6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSheet(Plan plan) {
    final phoneController = TextEditingController();
    bool isProcessing = false;
    String? paymentMessage;

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
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const Gap(24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: _getPlanGradient(plan.slug),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getPlanIcon(plan.slug),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const Gap(16),
                Text(
                  'Panda hadi ${plan.displayName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      plan.priceFormatted,
                      style: TextStyle(
                        color: _getPlanColor(plan.slug),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (plan.durationDays != null)
                      Text(
                        ' /siku ${plan.durationDays}',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                  ],
                ),
                const Gap(24),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Namba ya Simu (M-Pesa)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon: Icon(
                      Icons.phone_rounded,
                      color: _getPlanColor(plan.slug),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (paymentMessage != null) ...[
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF448AFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_rounded,
                          color: Color(0xFF448AFF),
                          size: 20,
                        ),
                        const Gap(10),
                        Expanded(
                          child: Text(
                            paymentMessage!,
                            style: const TextStyle(
                              color: Color(0xFF448AFF),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Gap(24),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _getPlanGradient(plan.slug),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () async {
                              if (phoneController.text.length < 10) return;
                              setSheetState(() {
                                isProcessing = true;
                                paymentMessage = 'Inatuma ombi...';
                              });

                              final result = await _planService.initiatePayment(
                                plan.id,
                                phoneController.text,
                              );

                              if (result.success && result.orderId != null) {
                                setSheetState(
                                  () => paymentMessage =
                                      result.instructions ??
                                      'Angalia simu yako',
                                );
                                _pollPaymentStatus(
                                  result.orderId!,
                                  setSheetState,
                                  (msg) =>
                                      setSheetState(() => paymentMessage = msg),
                                );
                              } else {
                                setSheetState(() {
                                  isProcessing = false;
                                  paymentMessage = result.message;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Lipa Sasa',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                    ),
                  ),
                ),
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      color: AppColors.textTertiary,
                      size: 14,
                    ),
                    const Gap(6),
                    Text(
                      'Malipo salama kupitia M-Pesa',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pollPaymentStatus(
    String orderId,
    StateSetter setSheetState,
    Function(String) onMessage,
  ) {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      final status = await _planService.checkPaymentStatus(orderId);

      if (status.isCompleted) {
        timer.cancel();
        if (mounted) {
          Navigator.pop(context);
          _showSuccessDialog();
          _loadData();
        }
      } else if (status.isFailed) {
        timer.cancel();
        onMessage(status.message);
        setSheetState(() {});
      } else {
        onMessage(status.message);
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00C853)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const Gap(20),
            const Text(
              'Hongera! 🎉',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              'Mpango wako umeanzishwa!',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const Gap(24),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Sawa'),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getPlanGradient(String slug) {
    switch (slug.toLowerCase()) {
      case 'free':
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
      case 'silver':
        return const LinearGradient(
          colors: [Color(0xFF94A3B8), Color(0xFF64748B)],
        );
      case 'gold':
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
        );
      case 'vip':
        return const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
        );
      default:
        return AppColors.primaryGradient;
    }
  }

  Color _getPlanColor(String slug) {
    switch (slug.toLowerCase()) {
      case 'free':
        return const Color(0xFF10B981);
      case 'silver':
        return const Color(0xFF94A3B8);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'vip':
        return const Color(0xFF7C4DFF);
      default:
        return AppColors.primary;
    }
  }

  IconData _getPlanIcon(String slug) {
    switch (slug.toLowerCase()) {
      case 'free':
        return Icons.card_giftcard_rounded;
      case 'silver':
        return Icons.star_rounded;
      case 'gold':
        return Icons.emoji_events_rounded;
      case 'vip':
        return Icons.diamond_rounded;
      default:
        return Icons.workspace_premium_rounded;
    }
  }
}
