import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskExecutionScreen extends StatefulWidget {
  final Task task;

  const TaskExecutionScreen({super.key, required this.task});

  @override
  State<TaskExecutionScreen> createState() => _TaskExecutionScreenState();
}

class _TaskExecutionScreenState extends State<TaskExecutionScreen> {
  late int _timeLeft;
  Timer? _timer;
  bool _isCompleted = false;
  WebViewController? _controller;
  bool _isLoadingWeb = true;
  String? _taskUrl;
  String? _error;
  double _loadProgress = 0;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.task.durationSeconds;

    // Initialize WebView immediately if URL exists
    if (widget.task.url != null && widget.task.url!.isNotEmpty) {
      _taskUrl = widget.task.url;
      _initWebView(_taskUrl!);
    }

    // Start API call in background
    _initializeTask();
  }

  Future<void> _initializeTask() async {
    try {
      // Start task on API to get the lock token and potentially updated URL
      final result = await context.read<TaskProvider>().startTask(
        widget.task.id,
      );

      if (result != null && mounted) {
        final newUrl = result['target_url'] ?? result['url'];

        // If we didn't have a URL before, or if API gives a different one, load it
        if (newUrl != null && newUrl.isNotEmpty && newUrl != _taskUrl) {
          setState(() {
            _taskUrl = newUrl;
          });
          if (_controller == null) {
            _initWebView(newUrl);
          } else {
            _controller!.loadRequest(Uri.parse(newUrl));
          }
        } else if (_taskUrl == null) {
          // Still no URL, start timer without WebView
          _startTimer();
        }
      }
    } catch (e) {
      // Log error but don't block user if they are already viewing the ad from widget.task.url
      debugPrint('Error starting task: $e');
    }
  }

  void _initWebView(String url) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoadingWeb = true);
          },
          onProgress: (progress) {
            if (mounted) setState(() => _loadProgress = progress / 100);
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => _isLoadingWeb = false);
              // Start timer when page finishes loading
              if (_timer == null) {
                _startTimer();
              }
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Handle error silently
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    setState(() {});
  }

  void _startTimer() {
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
    try {
      final result = await context.read<TaskProvider>().completeTask(
        widget.task.id,
      );
      if (mounted && result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const Gap(12),
                Expanded(
                  child: Text(
                    'Task Completed! +TZS ${result['reward_earned'] ?? widget.task.reward}',
                  ),
                ),
              ],
            ),
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (_taskUrl != null)
              Text(
                _taskUrl!,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        leading: IconButton(
          onPressed: () {
            context.read<TaskProvider>().cancelTask();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close_rounded),
        ),
        actions: [
          // Timer Badge
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _isCompleted ? AppColors.success : AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCompleted ? Icons.check_rounded : Icons.timer_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const Gap(6),
                    Text(
                      _isCompleted ? 'Done' : '${_timeLeft}s',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _isLoadingWeb
              ? LinearProgressIndicator(
                  value: _loadProgress,
                  backgroundColor: AppColors.surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  minHeight: 2,
                )
              : const SizedBox(height: 2),
        ),
      ),
      body: Column(
        children: [
          // WebView Content
          Expanded(
            child: _controller != null
                ? WebViewWidget(controller: _controller!)
                : _buildWaitingState(),
          ),

          // Browser Controls & Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Browser Controls
                  if (_controller != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 20,
                          ),
                          onPressed: () async {
                            if (await _controller!.canGoBack()) {
                              _controller!.goBack();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          onPressed: () => _controller!.reload(),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                          ),
                          onPressed: () async {
                            if (await _controller!.canGoForward()) {
                              _controller!.goForward();
                            }
                          },
                        ),
                      ],
                    ),

                  const Gap(8),

                  // Claim Button
                  Consumer<TaskProvider>(
                    builder: (context, provider, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isCompleted && !provider.isLoading
                              ? _completeTask
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isCompleted
                                ? AppColors.success
                                : AppColors.surface,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isCompleted
                                          ? Icons.check_circle_rounded
                                          : Icons.hourglass_empty_rounded,
                                      size: 22,
                                    ),
                                    const Gap(10),
                                    Text(
                                      _isCompleted
                                          ? 'Claim Reward'
                                          : 'Wait for timer...',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isCompleted
                          ? Icons.check_rounded
                          : Icons.hourglass_top_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .rotate(
                    begin: 0,
                    end: _isCompleted ? 0 : 0.1,
                    duration: 1.seconds,
                  ),
              const Gap(24),
              Text(
                _isCompleted ? 'Task Complete!' : 'Please wait...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              Text(
                _isCompleted
                    ? 'You can now claim your reward'
                    : 'Task will be ready in ${_timeLeft}s',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const Gap(20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+TZS ${widget.task.reward.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
