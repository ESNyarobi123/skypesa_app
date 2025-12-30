import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  int _currentStep = 0; // 0: Personal Info, 1: Security

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool _validateStep1() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Tafadhali weka jina lako');
      return false;
    }
    if (_nameController.text.trim().length < 2) {
      _showError('Jina lazima liwe na angalau herufi 2');
      return false;
    }
    if (_emailController.text.trim().isEmpty) {
      _showError('Tafadhali weka email yako');
      return false;
    }
    if (!_emailController.text.contains('@') ||
        !_emailController.text.contains('.')) {
      _showError('Tafadhali weka email sahihi');
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showError('Tafadhali weka namba ya simu');
      return false;
    }
    if (_phoneController.text.trim().length < 10) {
      _showError('Weka namba ya simu sahihi');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      final success = await context.read<AuthProvider>().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        referralCode: _referralController.text.trim().isNotEmpty
            ? _referralController.text.trim()
            : null,
      );

      if (success && mounted) {
        // Show success animation
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildSuccessDialog(),
        );

        // Navigate after animation
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(); // Close dialog
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        });
      } else if (mounted) {
        _showError(
          context.read<AuthProvider>().error ?? 'Usajili umeshindikana',
        );
      }
    } else if (!_acceptTerms) {
      _showError('Tafadhali kubali masharti ya kutumia');
    }
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                )
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut)
                .then()
                .shake(duration: 500.ms),
            const Gap(24),
            Text(
              'Karibu SKYpesa! 🎉',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const Gap(12),
            Text(
              context.read<AuthProvider>().successMessage ??
                  'Usajili umefanikiwa!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ).animate().fadeIn(delay: 400.ms),
            const Gap(24),
            // Animated progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    )
                    .animate(
                      delay: Duration(milliseconds: 100 * index),
                      onComplete: (controller) =>
                          controller.repeat(reverse: true),
                    )
                    .scale(duration: 600.ms);
              }),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          // Animated Background Elements
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) => Positioned(
              top: -80 + _floatAnimation.value,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      AppColors.primary.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) => Positioned(
              bottom: -100 - _floatAnimation.value,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.2),
                      AppColors.accent.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating particles
          ...List.generate(5, (index) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) => Positioned(
                top: 100 + (index * 150.0) + (_pulseController.value * 20),
                left: (index % 2 == 0 ? 20 : null),
                right: (index % 2 != 0 ? 20 : null),
                child: Opacity(
                  opacity: 0.3,
                  child: Container(
                    width: 8 + (index * 2.0),
                    height: 8 + (index * 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            );
          }),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _currentStep == 0
                        ? _buildPersonalInfoStep()
                        : _buildSecurityStep(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepDot(0, 'Taarifa'),
          _buildStepLine(0),
          _buildStepDot(1, 'Usalama'),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildStepDot(int index, String label) {
    final isActive = _currentStep >= index;
    final isCompleted = _currentStep > index;

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isActive ? AppColors.primaryGradient : null,
            color: isActive ? null : AppColors.surface,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.textTertiary,
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                : Icon(
                    index == 0 ? Icons.person_outline : Icons.lock_outline,
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    size: 22,
                  ),
          ),
        ),
        const Gap(8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int beforeIndex) {
    final isCompleted = _currentStep > beforeIndex;

    return Container(
      width: 80,
      height: 3,
      margin: const EdgeInsets.only(bottom: 28, left: 8, right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: isCompleted ? AppColors.primaryGradient : null,
        color: isCompleted ? null : AppColors.surface,
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      key: const ValueKey('step1'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Step Indicator
        _buildStepIndicator(),
        const Gap(24),

        // Header Section
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_add_rounded,
                color: Colors.white,
                size: 35,
              ),
            ).animate().fadeIn(duration: 500.ms).scale(delay: 100.ms),
          ],
        ),
        const Gap(24),

        // Title
        const Text(
          'Jiunge Nasi',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn(delay: 100.ms),
        const Gap(8),
        const Text(
          'Anza safari yako ya kupata mapato',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ).animate().fadeIn(delay: 200.ms),
        const Gap(32),

        // Form Card
        GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Full Name
              _buildAnimatedTextField(
                delay: 0,
                child: CustomTextField(
                  label: 'Jina Kamili',
                  hint: 'John Doe',
                  controller: _nameController,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tafadhali weka jina lako';
                    }
                    if (value.length < 2) {
                      return 'Jina lazima liwe na angalau herufi 2';
                    }
                    return null;
                  },
                ),
              ),
              const Gap(16),

              // Email
              _buildAnimatedTextField(
                delay: 50,
                child: CustomTextField(
                  label: 'Barua Pepe',
                  hint: 'email@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.email_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tafadhali weka email yako';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Tafadhali weka email sahihi';
                    }
                    return null;
                  },
                ),
              ),
              const Gap(16),

              // Phone
              _buildAnimatedTextField(
                delay: 100,
                child: CustomTextField(
                  label: 'Namba ya Simu',
                  hint: '07XXXXXXXX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.phone_android_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tafadhali weka namba ya simu';
                    }
                    if (value.length < 10) {
                      return 'Weka namba ya simu sahihi';
                    }
                    return null;
                  },
                ),
              ),
              const Gap(24),

              // Next Button
              PrimaryButton(
                text: 'Endelea',
                onPressed: () {
                  if (_validateStep1()) {
                    setState(() => _currentStep = 1);
                  }
                },
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

        const Gap(24),

        // Login Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tayari una akaunti? ',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Ingia',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildSecurityStep() {
    return Column(
      key: const ValueKey('step2'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Step Indicator
        _buildStepIndicator(),
        const Gap(24),

        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: Colors.white,
                size: 35,
              ),
            ).animate().fadeIn(duration: 500.ms).scale(delay: 100.ms),
          ],
        ),
        const Gap(24),

        // Title
        const Text(
          'Weka Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn(delay: 100.ms),
        const Gap(8),
        const Text(
          'Unda password ya usalama',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ).animate().fadeIn(delay: 200.ms),
        const Gap(32),

        // Form Card
        GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Password
              _buildAnimatedTextField(
                delay: 0,
                child: CustomTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tafadhali weka password';
                    }
                    if (value.length < 6) {
                      return 'Password lazima iwe na angalau herufi 6';
                    }
                    return null;
                  },
                ),
              ),
              const Gap(16),

              // Confirm Password
              _buildAnimatedTextField(
                delay: 50,
                child: CustomTextField(
                  label: 'Thibitisha Password',
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      );
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tafadhali thibitisha password';
                    }
                    if (value != _passwordController.text) {
                      return 'Password hazilingani';
                    }
                    return null;
                  },
                ),
              ),
              const Gap(16),

              // Referral Code
              _buildAnimatedTextField(
                delay: 100,
                child: CustomTextField(
                  label: 'Kodi ya Mwaliko (Si lazima)',
                  hint: 'Weka kodi ya mwaliko',
                  controller: _referralController,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.card_giftcard_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

        const Gap(16),

        // Password Strength Indicator
        _buildPasswordStrength(),

        const Gap(16),

        // Terms Checkbox
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: _acceptTerms ? AppColors.primaryGradient : null,
                    border: Border.all(
                      color: _acceptTerms
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      width: 2,
                    ),
                  ),
                  child: _acceptTerms
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const Gap(12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      children: [
                        const TextSpan(text: 'Nakubali '),
                        TextSpan(
                          text: 'Masharti ya Kutumia',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' na '),
                        TextSpan(
                          text: 'Sera ya Faragha',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),

        const Gap(24),

        // Register Button
        Consumer<AuthProvider>(
          builder: (context, auth, child) {
            return PrimaryButton(
              text: 'Jisajili',
              isLoading: auth.isLoading,
              onPressed: _acceptTerms ? _handleRegister : null,
            );
          },
        ).animate().fadeIn(delay: 450.ms),

        const Gap(16),

        // Back to Login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tayari una akaunti? ',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Ingia',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildPasswordStrength() {
    final password = _passwordController.text;
    final strength = _calculatePasswordStrength(password);

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nguvu ya Password',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                strength.label,
                style: TextStyle(
                  color: strength.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Gap(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: strength.value,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation(strength.color),
              minHeight: 6,
            ),
          ),
          const Gap(16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRequirementChip('Herufi 6+', password.length >= 6),
              _buildRequirementChip(
                'Herufi kubwa',
                password.contains(RegExp(r'[A-Z]')),
              ),
              _buildRequirementChip(
                'Namba',
                password.contains(RegExp(r'[0-9]')),
              ),
              _buildRequirementChip(
                'Alama maalum',
                password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms);
  }

  Widget _buildRequirementChip(String label, bool isMet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isMet ? AppColors.success.withOpacity(0.15) : AppColors.surface,
        border: Border.all(
          color: isMet ? AppColors.success : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: isMet ? AppColors.success : AppColors.textTertiary,
          ),
          const Gap(6),
          Text(
            label,
            style: TextStyle(
              color: isMet ? AppColors.success : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength('Hakuna', 0, AppColors.textTertiary);
    }

    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 1) {
      return PasswordStrength('Dhaifu', 0.2, AppColors.error);
    } else if (score == 2) {
      return PasswordStrength('Wastani', 0.4, AppColors.warning);
    } else if (score == 3) {
      return PasswordStrength('Nzuri', 0.6, const Color(0xFFFFA726));
    } else if (score == 4) {
      return PasswordStrength('Imara', 0.8, AppColors.success);
    } else {
      return PasswordStrength('Bora sana!', 1.0, AppColors.primary);
    }
  }

  Widget _buildAnimatedTextField({required int delay, required Widget child}) {
    return child
        .animate(delay: Duration(milliseconds: 300 + delay))
        .fadeIn()
        .slideX(begin: 0.1, end: 0);
  }
}

class PasswordStrength {
  final String label;
  final double value;
  final Color color;

  PasswordStrength(this.label, this.value, this.color);
}
