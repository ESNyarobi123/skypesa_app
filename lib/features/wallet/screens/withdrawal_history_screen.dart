import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../services/wallet_service.dart';

class WithdrawalHistoryScreen extends StatefulWidget {
  const WithdrawalHistoryScreen({super.key});

  @override
  State<WithdrawalHistoryScreen> createState() =>
      _WithdrawalHistoryScreenState();
}

class _WithdrawalHistoryScreenState extends State<WithdrawalHistoryScreen> {
  final _walletService = WalletService();
  List<WithdrawalData> _withdrawals = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWithdrawals();
  }

  Future<void> _loadWithdrawals({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final result = await _walletService.getWithdrawals(page: _currentPage);
      setState(() {
        if (refresh || _currentPage == 1) {
          _withdrawals = result.withdrawals;
        } else {
          _withdrawals.addAll(result.withdrawals);
        }
        _lastPage = result.lastPage;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentPage >= _lastPage) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    await _loadWithdrawals();
  }

  Future<void> _cancelWithdrawal(WithdrawalData withdrawal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.cancel_outlined,
                color: AppColors.warning,
                size: 22,
              ),
            ),
            const Gap(14),
            const Text(
              'Futa Ombi?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Una uhakika unataka kufuta ombi hili?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDialogRow('Reference', withdrawal.reference),
                  const Gap(6),
                  _buildDialogRow(
                    'Kiasi',
                    'TZS ${withdrawal.amount.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ),
            const Gap(12),
            Text(
              'Pesa itarudi kwenye wallet yako.',
              style: TextStyle(color: AppColors.success, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Hapana',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context, true),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Ndio, Futa',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _walletService.cancelWithdrawal(withdrawal.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  result.success
                      ? Icons.check_circle_rounded
                      : Icons.error_rounded,
                  color: Colors.white,
                ),
                const Gap(10),
                Expanded(child: Text(result.message)),
              ],
            ),
            backgroundColor: result.success
                ? AppColors.success
                : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        if (result.success) {
          _loadWithdrawals(refresh: true);
        }
      }
    }
  }

  Widget _buildDialogRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Historia ya Withdrawals',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.error,
            ),
          ),
          const Gap(20),
          const Text(
            'Imeshindikana',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(_error!, style: TextStyle(color: AppColors.textSecondary)),
          const Gap(20),
          ElevatedButton.icon(
            onPressed: () => _loadWithdrawals(refresh: true),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Jaribu Tena'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_withdrawals.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadWithdrawals(refresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 100) {
            _loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: _withdrawals.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _withdrawals.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final withdrawal = _withdrawals[index];
            return _buildWithdrawalCard(withdrawal, index);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 56,
              color: AppColors.textTertiary,
            ),
          ),
          const Gap(20),
          const Text(
            'Hakuna Maombi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(
            'Hujafanya ombi lolote la kutoa pesa',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const Gap(24),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/withdraw'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Toa Pesa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalCard(WithdrawalData withdrawal, int index) {
    final statusInfo = _getStatusInfo(withdrawal.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.card, AppColors.surface.withOpacity(0.5)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusInfo.color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showWithdrawalDetails(withdrawal),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    // Provider icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getProviderColor(withdrawal.paymentProvider),
                            _getProviderColor(
                              withdrawal.paymentProvider,
                            ).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _getProviderColor(
                              withdrawal.paymentProvider,
                            ).withOpacity(0.3),
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
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getProviderName(withdrawal.paymentProvider),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            withdrawal.paymentNumber,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TZS ${withdrawal.netAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: statusInfo.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const Gap(4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusInfo.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusInfo.icon,
                                color: statusInfo.color,
                                size: 12,
                              ),
                              const Gap(4),
                              Text(
                                statusInfo.label,
                                style: TextStyle(
                                  color: statusInfo.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(14),
                const Divider(color: AppColors.surface, height: 1),
                const Gap(14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tag_rounded,
                          color: AppColors.textTertiary,
                          size: 14,
                        ),
                        const Gap(4),
                        Text(
                          withdrawal.reference,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: AppColors.textTertiary,
                          size: 14,
                        ),
                        const Gap(4),
                        Text(
                          _formatDate(withdrawal.createdAt),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (withdrawal.canCancel)
                      InkWell(
                        onTap: () => _cancelWithdrawal(withdrawal),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Futa',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (60 * index).ms, duration: 400.ms);
  }

  void _showWithdrawalDetails(WithdrawalData withdrawal) {
    final statusInfo = _getStatusInfo(withdrawal.status);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.card, const Color(0xFF1A1A2E)],
          ),
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
              // Status icon
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusInfo.color,
                      statusInfo.color.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusInfo.color.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(statusInfo.icon, color: Colors.white, size: 36),
              ),
              const Gap(18),
              Text(
                statusInfo.label,
                style: TextStyle(
                  color: statusInfo.color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(24),
              // Details
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _detailRow('Reference', withdrawal.reference),
                    _divider(),
                    _detailRow(
                      'Provider',
                      _getProviderName(withdrawal.paymentProvider),
                    ),
                    _divider(),
                    _detailRow('Phone', withdrawal.paymentNumber),
                    _divider(),
                    _detailRow('Name', withdrawal.paymentName),
                    _divider(),
                    _detailRow(
                      'Kiasi',
                      'TZS ${withdrawal.amount.toStringAsFixed(0)}',
                    ),
                    _divider(),
                    _detailRow(
                      'Fee',
                      '- TZS ${withdrawal.fee.toStringAsFixed(0)}',
                      valueColor: AppColors.error,
                    ),
                    _divider(),
                    _detailRow(
                      'Net Amount',
                      'TZS ${withdrawal.netAmount.toStringAsFixed(0)}',
                      valueColor: AppColors.success,
                      isBold: true,
                    ),
                    _divider(),
                    _detailRow('Date', _formatDate(withdrawal.createdAt)),
                  ],
                ),
              ),
              if (withdrawal.canCancel) ...[
                const Gap(20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _cancelWithdrawal(withdrawal);
                    },
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Futa Ombi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: AppColors.card, height: 1);

  _StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return _StatusInfo(
          'Inasubiri',
          AppColors.warning,
          Icons.pending_rounded,
        );
      case 'processing':
        return _StatusInfo(
          'Inachakatwa',
          const Color(0xFF448AFF),
          Icons.sync_rounded,
        );
      case 'approved':
        return _StatusInfo(
          'Imekubaliwa',
          const Color(0xFF00E676),
          Icons.thumb_up_rounded,
        );
      case 'paid':
        return _StatusInfo(
          'Imelipwa',
          AppColors.success,
          Icons.check_circle_rounded,
        );
      case 'rejected':
        return _StatusInfo(
          'Imekataliwa',
          AppColors.error,
          Icons.cancel_rounded,
        );
      case 'cancelled':
        return _StatusInfo(
          'Imefutwa',
          AppColors.textTertiary,
          Icons.remove_circle_rounded,
        );
      default:
        return _StatusInfo(
          'Unknown',
          AppColors.textSecondary,
          Icons.help_outline_rounded,
        );
    }
  }

  Color _getProviderColor(String provider) {
    switch (provider.toLowerCase()) {
      case 'mpesa':
        return const Color(0xFFE11D48);
      case 'tigopesa':
        return const Color(0xFF0EA5E9);
      case 'airtelmoney':
        return const Color(0xFFDC2626);
      case 'halopesa':
        return const Color(0xFFF97316);
      default:
        return AppColors.primary;
    }
  }

  String _getProviderName(String provider) {
    switch (provider.toLowerCase()) {
      case 'mpesa':
        return 'M-Pesa';
      case 'tigopesa':
        return 'Tigo Pesa';
      case 'airtelmoney':
        return 'Airtel Money';
      case 'halopesa':
        return 'Halo Pesa';
      default:
        return provider;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  final IconData icon;

  _StatusInfo(this.label, this.color, this.icon);
}
