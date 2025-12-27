import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/wallet_provider.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedMethod = 'M-Pesa';

  final List<String> _methods = [
    'M-Pesa',
    'Tigo Pesa',
    'Airtel Money',
    'HaloPesa',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _handleWithdraw() async {
    if (_formKey.currentState!.validate()) {
      try {
        final amount = double.parse(_amountController.text);
        final message = await context.read<WalletProvider>().withdraw(
          amount: amount,
          method: _selectedMethod,
          accountNumber: _accountController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw Funds')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(12),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _methods.length,
                  separatorBuilder: (context, index) => const Gap(12),
                  itemBuilder: (context, index) {
                    final method = _methods[index];
                    final isSelected = _selectedMethod == method;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMethod = method;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.2)
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const Gap(8),
                            Text(
                              method,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Gap(32),

              GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Amount (Tsh)',
                      hint: 'Min: 1000',
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(
                        Icons.attach_money,
                        color: AppColors.textSecondary,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final amount = double.tryParse(value);
                        if (amount == null || amount < 1000)
                          return 'Min withdrawal is 1000';
                        return null;
                      },
                    ),
                    const Gap(16),
                    CustomTextField(
                      label: 'Phone Number',
                      hint: '07...',
                      controller: _accountController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: AppColors.textSecondary,
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),

              const Gap(32),

              Consumer<WalletProvider>(
                builder: (context, provider, child) {
                  return PrimaryButton(
                    text: 'Confirm Withdrawal',
                    isLoading: provider.isLoading,
                    onPressed: _handleWithdraw,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
