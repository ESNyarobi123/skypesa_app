import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../services/wallet_service.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _walletService = WalletService();

  WithdrawalInfo? _withdrawalInfo;
  PaymentProvider? _selectedProvider;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  // Calculated values
  double _feeAmount = 0;
  double _netAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadWithdrawalInfo();
    _amountController.addListener(_calculateFee);
  }

  @override
  void dispose() {
    _amountController.removeListener(_calculateFee);
    _amountController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadWithdrawalInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final info = await _walletService.getWithdrawalInfo();
      if (info != null) {
        setState(() {
          _withdrawalInfo = info;
          _isLoading = false;
          // Pre-select first provider
          if (info.paymentProviders.isNotEmpty) {
            _selectedProvider = info.paymentProviders.first;
          }
          // Pre-fill user info
          _phoneController.text = info.userPhone;
          _nameController.text = info.userName;
        });
      } else {
        setState(() {
          _error = 'Failed to load withdrawal information';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _calculateFee() {
    if (_withdrawalInfo == null) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _feeAmount = _withdrawalInfo!.calculateFee(amount);
      _netAmount = _withdrawalInfo!.calculateNetAmount(amount);
    });
  }

  Future<void> _handleWithdraw() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProvider == null) {
      _showError('Tafadhali chagua mtoa huduma');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final amount = double.parse(_amountController.text);
      final result = await _walletService.createWithdrawal(
        amount: amount,
        paymentProvider: _selectedProvider!.id,
        paymentNumber: _phoneController.text,
        paymentName: _nameController.text,
      );

      setState(() => _isSubmitting = false);

      if (result.success) {
        _showSuccessDialog(result);
      } else {
        _showError(result.message);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const Gap(10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog(WithdrawalResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success,
                    AppColors.success.withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const Gap(24),
            const Text(
              'Ombi Limepokelewa!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),
            Text(
              result.message,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (result.data != null) ...[
              const Gap(20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Reference', result.data!.reference),
                    const Gap(8),
                    _buildInfoRow(
                      'Utapata',
                      'TZS ${result.data!.netAmount.toStringAsFixed(0)}',
                      valueColor: AppColors.success,
                    ),
                    const Gap(8),
                    _buildInfoRow(
                      'Muda',
                      '${result.data!.delayHours ?? 24} Saa',
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
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Sawa, Nimuelewa',
                    style: TextStyle(
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
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Withdraw Funds',
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
      ),
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E676).withOpacity(0.15),
                    const Color(0xFF00E676).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorState()
              : _buildContent(),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error.withOpacity(0.7),
              ),
            ),
            const Gap(20),
            const Text(
              'Imeshindikana Kupakia',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              _error!,
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            ElevatedButton.icon(
              onPressed: _loadWithdrawalInfo,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Jaribu Tena'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final info = _withdrawalInfo!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            _buildBalanceCard(info),

            const Gap(24),

            // Warning if pending withdrawal exists
            if (info.pendingWithdrawalsCount > 0) ...[
              _buildPendingWarning(info),
              const Gap(20),
            ],

            // Payment Providers
            _buildPaymentProviders(info),

            const Gap(24),

            // Form Fields
            _buildFormSection(info),

            const Gap(24),

            // Fee Summary
            if (_amountController.text.isNotEmpty) ...[
              _buildFeeSummary(info),
              const Gap(24),
            ],

            // Submit Button
            _buildSubmitButton(info),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WithdrawalInfo info) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withOpacity(0.25),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF00E676),
                    Color(0xFF00C853),
                    Color(0xFF00695C),
                  ],
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const Gap(12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(14),
                  Text(
                    'TZS ${info.balance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (info.pendingWithdrawal > 0) ...[
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pending_rounded,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const Gap(4),
                          Text(
                            'Pending: TZS ${info.pendingWithdrawal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Gap(16),
                  Row(
                    children: [
                      _buildInfoChip(
                        'Min: TZS ${info.minWithdrawal.toStringAsFixed(0)}',
                        Icons.remove_circle_outline_rounded,
                      ),
                      const Gap(12),
                      _buildInfoChip(
                        'Fee: ${info.withdrawalFeePercent.toStringAsFixed(0)}%',
                        Icons.percent_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1);
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const Gap(6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingWarning(WithdrawalInfo info) {
    return Container(
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Una Ombi Linalosubiri',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Gap(2),
                Text(
                  '${info.pendingWithdrawalsCount} ombi linasubiri kuchakatwa',
                  style: TextStyle(
                    color: AppColors.warning.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).shake();
  }

  Widget _buildPaymentProviders(WithdrawalInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.payment_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const Gap(12),
            const Text(
              'Chagua Mtoa Huduma',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Gap(16),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: info.paymentProviders.length,
            separatorBuilder: (_, __) => const Gap(12),
            itemBuilder: (context, index) {
              final provider = info.paymentProviders[index];
              final isSelected = _selectedProvider?.id == provider.id;
              final color = _parseColor(provider.color);

              return InkWell(
                onTap: () => setState(() => _selectedProvider = provider),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 100,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withOpacity(0.3),
                              color.withOpacity(0.1),
                            ],
                          )
                        : null,
                    color: isSelected ? null : AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? color : AppColors.surface,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.phone_android_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const Gap(10),
                      Text(
                        provider.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? color : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  Widget _buildFormSection(WithdrawalInfo info) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.card, const Color(0xFF1A1A2E)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.surface),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Amount Field
          CustomTextField(
            label: 'Kiasi (TZS)',
            hint: 'Min: ${info.minWithdrawal.toStringAsFixed(0)}',
            controller: _amountController,
            keyboardType: TextInputType.number,
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00C853)],
                ).createShader(bounds),
                child: const Icon(
                  Icons.attach_money_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Tafadhali weka kiasi';
              final amount = double.tryParse(value);
              if (amount == null) return 'Kiasi si sahihi';
              if (amount < info.minWithdrawal) {
                return 'Kiwango cha chini ni TZS ${info.minWithdrawal.toStringAsFixed(0)}';
              }
              if (amount > info.balance) {
                return 'Huna salio la kutosha';
              }
              return null;
            },
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const Gap(18),

          // Phone Field
          CustomTextField(
            label: 'Namba ya Simu',
            hint: '07XXXXXXXX',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.phone_android_rounded,
                color: _selectedProvider != null
                    ? _parseColor(_selectedProvider!.color)
                    : AppColors.textSecondary,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Tafadhali weka namba ya simu';
              }
              if (value.length < 10 || value.length > 15) {
                return 'Namba ya simu si sahihi';
              }
              return null;
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
          ),
          const Gap(18),

          // Name Field
          CustomTextField(
            label: 'Jina la Mwenye Akaunti',
            hint: 'Jina Kamili',
            controller: _nameController,
            keyboardType: TextInputType.name,
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.textSecondary,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Tafadhali weka jina';
              }
              if (value.length < 3) {
                return 'Jina fupi sana';
              }
              return null;
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildFeeSummary(WithdrawalInfo info) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calculate_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const Gap(12),
              const Text(
                'Muhtasari',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Gap(16),
          _buildSummaryRow('Kiasi', 'TZS ${amount.toStringAsFixed(0)}'),
          const Gap(8),
          _buildSummaryRow(
            'Fee (${info.withdrawalFeePercent.toStringAsFixed(0)}%)',
            '- TZS ${_feeAmount.toStringAsFixed(0)}',
            valueColor: AppColors.error,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.surface),
          ),
          _buildSummaryRow(
            'Utapata',
            'TZS ${_netAmount.toStringAsFixed(0)}',
            valueColor: const Color(0xFF00E676),
            isBold: true,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: isBold ? 18 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(WithdrawalInfo info) {
    final canSubmit =
        info.canWithdraw && _selectedProvider != null && !_isSubmitting;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: canSubmit
            ? const LinearGradient(
                colors: [Color(0xFF00E676), Color(0xFF00C853)],
              )
            : null,
        color: canSubmit ? null : AppColors.surface,
        boxShadow: canSubmit
            ? [
                BoxShadow(
                  color: const Color(0xFF00E676).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: canSubmit ? _handleWithdraw : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_rounded,
                    color: canSubmit ? Colors.white : AppColors.textTertiary,
                    size: 22,
                  ),
                  const Gap(10),
                  Text(
                    'Tuma Ombi la Kutoa',
                    style: TextStyle(
                      color: canSubmit ? Colors.white : AppColors.textTertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }
}
