import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskExecutionScreen extends StatefulWidget {
  final Task task;

  const TaskExecutionScreen({super.key, required this.task});

  @override
  State<TaskExecutionScreen> createState() => _TaskExecutionScreenState();
}

class _TaskExecutionScreenState extends State<TaskExecutionScreen>
    with TickerProviderStateMixin {
  late int _timeLeft;
  late int _totalDuration;
  Timer? _timer;
  bool _isCompleted = false;
  WebViewController? _controller;
  bool _isLoadingWeb = true;
  String? _error;
  double _loadProgress = 0;
  bool _isInitialized = false;
  bool _isStartingTask = true;
  bool _isCompletingTask = false;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _timerController;

  // Default fallback URLs for ads
  static const List<String> _fallbackAdUrls = [
    'https://www.effectivegatetocontent.com/nmjxz3d6?key=ecd4e48a9fcc0fa416c2e8cb87a02e41',
    'https://www.profitabledisplaynetwork.com/pfe51w09?key=a35b91f43d8fc9c72a9dbf6f67e4e76d',
  ];

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.task.durationSeconds;
    _totalDuration = widget.task.durationSeconds;

    // Initialize animation controllers
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalDuration),
    );

    // Start the initialization process
    _initializeTask();
  }

  Future<void> _initializeTask() async {
    setState(() {
      _isStartingTask = true;
      _error = null;
    });

    try {
      debugPrint('=== STARTING TASK ${widget.task.id} ===');

      // Start task on API to get the lock token and URL
      final result = await context.read<TaskProvider>().startTask(
        widget.task.id,
      );

      debugPrint('=== API RESULT: $result ===');

      if (result != null && mounted) {
        // Try to get URL from API response - API returns 'task_url'
        final newUrl =
            result['task_url'] ??
            result['target_url'] ??
            result['url'] ??
            result['ad_url'];

        debugPrint('=== EXTRACTED URL: $newUrl ===');

        if (newUrl != null && newUrl.toString().isNotEmpty) {
          _loadWebViewWithUrl(newUrl.toString());
        } else {
          debugPrint('=== NO URL IN API RESPONSE, USING FALLBACK ===');
          _loadWebViewWithUrl(_getRandomFallbackUrl());
        }
      } else {
        debugPrint('=== API RESULT IS NULL, USING FALLBACK ===');
        _loadWebViewWithUrl(_getRandomFallbackUrl());
      }
    } catch (e) {
      debugPrint('=== ERROR STARTING TASK: $e ===');
      setState(() {
        _error = e.toString();
        _isStartingTask = false;
      });
    }
  }

  String _getRandomFallbackUrl() {
    // Use widget.task.url if available, otherwise use a random fallback
    if (widget.task.url != null && widget.task.url!.isNotEmpty) {
      return widget.task.url!;
    }
    final index =
        DateTime.now().millisecondsSinceEpoch % _fallbackAdUrls.length;
    return _fallbackAdUrls[index];
  }

  void _loadWebViewWithUrl(String url) {
    debugPrint('=== LOADING WEBVIEW WITH URL: $url ===');

    if (!mounted) return;

    // Handle intent:// URLs - extract the real URL before loading
    String actualUrl = url;
    if (url.startsWith('intent://')) {
      final extractedUrl = _extractUrlFromIntent(url);
      if (extractedUrl != null) {
        debugPrint('=== CONVERTED INTENT URL TO: $extractedUrl ===');
        actualUrl = extractedUrl;
      } else {
        // If we can't extract, use fallback
        debugPrint('=== COULD NOT EXTRACT FROM INTENT, USING FALLBACK ===');
        actualUrl = _getRandomFallbackUrl();
      }
    }

    setState(() {
      _isInitialized = true;
      _isLoadingWeb = true;
      _isStartingTask = false;
      _error = null;
    });

    // Timeout logic
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isLoadingWeb) {
        setState(() {
          _isLoadingWeb = false;
          _error =
              'Muda wa kupakia umeisha. Tafadhali jaribu tena au angalia mtandao wako.';
        });
      }
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint('=== NAVIGATION REQUEST: $url ===');

            // Handle intent:// URLs - extract the real URL
            if (url.startsWith('intent://')) {
              // Try to extract the actual URL from intent
              // Format: intent://domain/path#Intent;scheme=https;...
              final extractedUrl = _extractUrlFromIntent(url);
              if (extractedUrl != null) {
                debugPrint('=== EXTRACTED URL FROM INTENT: $extractedUrl ===');
                // Load the extracted URL instead
                _controller?.loadRequest(Uri.parse(extractedUrl));
                return NavigationDecision.prevent;
              }
            }

            // Block non-http schemes that WebView can't handle
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              debugPrint('=== BLOCKING NON-HTTP URL: $url ===');
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            debugPrint('=== PAGE STARTED: $url ===');
            if (mounted) setState(() => _isLoadingWeb = true);
          },
          onProgress: (progress) {
            if (mounted) setState(() => _loadProgress = progress / 100);
          },
          onPageFinished: (String url) {
            debugPrint('=== PAGE FINISHED: $url ===');
            if (mounted) {
              setState(() => _isLoadingWeb = false);
              // Start timer when page finishes loading
              if (_timer == null) {
                _startTimer();
              }
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('=== WEBVIEW ERROR: ${error.description} ===');
            // Only show error if it's a critical failure and we haven't loaded yet
            if (mounted && _timer == null) {
              // If it's a timeout or connection error, show error state
              if (error.description.contains('net::ERR_CONNECTION_TIMED_OUT') ||
                  error.description.contains('net::ERR_NAME_NOT_RESOLVED') ||
                  error.description.contains(
                    'net::ERR_INTERNET_DISCONNECTED',
                  )) {
                setState(() {
                  _isLoadingWeb = false;
                  _error = 'Tatizo la mtandao: ${error.description}';
                });
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(actualUrl));

    setState(() {});
  }

  /// Extract the actual HTTPS URL from an intent:// URL
  String? _extractUrlFromIntent(String intentUrl) {
    try {
      // Format: intent://domain/path?query#Intent;scheme=https;package=...;end
      // We need to extract: https://domain/path?query

      // Remove 'intent://' prefix
      var url = intentUrl.replaceFirst('intent://', '');

      // Split by '#Intent'
      final parts = url.split('#Intent');
      if (parts.isEmpty) return null;

      final pathPart = parts[0]; // domain/path?query

      // Find the scheme from the Intent parameters
      String scheme = 'https'; // Default to https
      if (parts.length > 1) {
        final intentParams = parts[1];
        final schemeMatch = RegExp(r'scheme=(\w+)').firstMatch(intentParams);
        if (schemeMatch != null) {
          scheme = schemeMatch.group(1) ?? 'https';
        }
      }

      // Construct the full URL
      final fullUrl = '$scheme://$pathPart';
      debugPrint('=== CONSTRUCTED URL: $fullUrl ===');

      // Validate it's a proper URL
      final uri = Uri.tryParse(fullUrl);
      if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
        return fullUrl;
      }

      return null;
    } catch (e) {
      debugPrint('=== ERROR EXTRACTING URL: $e ===');
      return null;
    }
  }

  void _startTimer() {
    debugPrint('=== TIMER STARTED ===');
    _timerController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isCompleted = true;
        });
      }
    });
  }

  Future<void> _completeTask() async {
    if (_isCompletingTask) return;

    setState(() {
      _isCompletingTask = true;
    });

    try {
      final result = await context.read<TaskProvider>().completeTask(
        widget.task.id,
      );
      if (mounted && result != null) {
        _showSuccessDialog(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const Gap(12),
                Expanded(child: Text(e.toString())),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        setState(() {
          _isCompletingTask = false;
        });
      }
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    final reward =
        result['reward'] ?? result['reward_earned'] ?? widget.task.reward;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.card, AppColors.surface],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.success.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Check Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.5),
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
              ).animate().scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),

              const Gap(24),

              // Success Text
              const Text(
                '🎉 Hongera! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const Gap(8),

              Text(
                'Umekamilisha task!',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 300.ms),

              const Gap(20),

              // Reward Amount
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withOpacity(0.2),
                      AppColors.primaryDark.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: AppColors.accent,
                      size: 32,
                    ),
                    const Gap(12),
                    Text(
                      '+TZS ${(reward is num ? reward : double.tryParse(reward.toString()) ?? 0).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.3, end: 0, delay: 400.ms).fadeIn(),

              const Gap(24),

              // Continue Button
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(
                          context,
                          true,
                        ); // Return to task list with success
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                            ),
                            Gap(8),
                            Text(
                              'Endelea',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await context.read<TaskProvider>().cancelTask();
          if (mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Custom App Bar with Timer
              _buildCustomAppBar(),

              // WebView Content
              Expanded(child: _buildContent()),

              // Bottom Action Bar
              _buildBottomActionBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    final progress = (_totalDuration - _timeLeft) / _totalDuration;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Close Button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () async {
                    await context.read<TaskProvider>().cancelTask();
                    if (mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close_rounded, size: 22),
                  color: AppColors.textSecondary,
                ),
              ),

              const Gap(12),

              // Task Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isLoadingWeb
                                ? AppColors.warning
                                : AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          _isStartingTask
                              ? 'Inaandaa...'
                              : (_isLoadingWeb ? 'Inapakia...' : 'Inaendelea'),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Timer Badge
              _buildAnimatedTimer(),
            ],
          ),

          const Gap(12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Background
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Progress
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 6,
                  width: MediaQuery.of(context).size.width * progress * 0.9,
                  decoration: BoxDecoration(
                    gradient: _isCompleted
                        ? AppColors.primaryGradient
                        : LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.7),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTimer() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: _isCompleted
                ? AppColors.primaryGradient
                : LinearGradient(colors: [AppColors.surface, AppColors.card]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isCompleted
                  ? AppColors.success
                  : AppColors.primary.withOpacity(
                      0.3 + (_pulseController.value * 0.4),
                    ),
              width: 2,
            ),
            boxShadow: _isCompleted
                ? [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.4),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isCompleted ? Icons.check_circle_rounded : Icons.timer_rounded,
                color: _isCompleted ? Colors.white : AppColors.primary,
                size: 20,
              ),
              const Gap(8),
              Text(
                _isCompleted ? 'Tayari!' : _formatTime(_timeLeft),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _isCompleted ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    if (seconds >= 60) {
      final mins = seconds ~/ 60;
      final secs = seconds % 60;
      return '${mins}:${secs.toString().padLeft(2, '0')}';
    }
    return '${seconds}s';
  }

  Widget _buildContent() {
    // Show loading while starting task
    if (_isStartingTask) {
      return _buildLoadingState('Inaandaa kazi...', 'Tafadhali subiri');
    }

    // Show error if there's an error and no webview
    if (_error != null && _controller == null) {
      return _buildErrorState();
    }

    // Show WebView if initialized
    if (_controller != null) {
      return Stack(
        children: [
          // WebView with container
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surface, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: WebViewWidget(controller: _controller!),
            ),
          ),

          // Loading overlay with blur effect
          if (_isLoadingWeb)
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated loading icon
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ring
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: _loadProgress > 0 ? _loadProgress : null,
                            strokeWidth: 4,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        // Inner icon
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.public_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),
                    Text(
                      'Inapakia content...',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_loadProgress > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${(_loadProgress * 100).toInt()}%',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    // Fallback loading state
    return _buildLoadingState('Inaandaa...', 'Tafadhali subiri');
  }

  Widget _buildLoadingState(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loading icon
            Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .rotate(begin: 0, end: 0.15, duration: 1.seconds),

            const Gap(32),

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
              subtitle,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),

            const Gap(24),

            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 2),
      ),
      padding: const EdgeInsets.all(32),
      child: Center(
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
                size: 64,
                color: AppColors.error,
              ),
            ),
            const Gap(24),
            const Text(
              'Imeshindikana kupakia',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _error ?? 'Tatizo halijulikani',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
            const Gap(32),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _initializeTask,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, color: Colors.white),
                        Gap(8),
                        Text(
                          'Jaribu Tena',
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Browser Controls
          if (_controller != null && !_isStartingTask)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBrowserButton(
                  icon: Icons.arrow_back_ios_rounded,
                  onPressed: () async {
                    if (await _controller!.canGoBack()) {
                      _controller!.goBack();
                    }
                  },
                ),
                const Gap(16),
                _buildBrowserButton(
                  icon: Icons.refresh_rounded,
                  onPressed: () => _controller!.reload(),
                ),
                const Gap(16),
                _buildBrowserButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onPressed: () async {
                    if (await _controller!.canGoForward()) {
                      _controller!.goForward();
                    }
                  },
                ),
              ],
            ),

          const Gap(12),

          // Main Action Button
          SizedBox(
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: _isCompleted ? AppColors.primaryGradient : null,
                    color: _isCompleted ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isCompleted
                        ? [
                            BoxShadow(
                              color: AppColors.success.withOpacity(
                                0.3 + (_pulseController.value * 0.3),
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                    border: Border.all(
                      color: _isCompleted
                          ? AppColors.success
                          : AppColors.surface,
                      width: 2,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isCompleted && !_isCompletingTask
                          ? _completeTask
                          : null,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: _isCompletingTask
                            ? const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isCompleted
                                        ? Icons.celebration_rounded
                                        : Icons.hourglass_bottom_rounded,
                                    size: 24,
                                    color: _isCompleted
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                  const Gap(12),
                                  Text(
                                    _isCompleted
                                        ? 'Pata +TZS ${widget.task.reward.toStringAsFixed(0)} 🎉'
                                        : 'Subiri ${_formatTime(_timeLeft)}...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: _isCompleted
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowserButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
