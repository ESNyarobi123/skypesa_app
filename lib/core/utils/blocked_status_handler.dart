import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Mixin to add blocked status checking to any screen
/// Use this for protected screens that should redirect blocked users
mixin BlockedStatusChecker<T extends StatefulWidget> on State<T> {
  bool _isCheckingBlockedStatus = false;

  /// Check if user is blocked and redirect if necessary
  /// Call this in initState or when resuming the app
  Future<void> checkBlockedStatusAndRedirect() async {
    if (_isCheckingBlockedStatus) return;
    _isCheckingBlockedStatus = true;

    try {
      final authProvider = context.read<AuthProvider>();
      final blockedInfo = await authProvider.checkBlockedStatus();

      if (!mounted) return;

      if (blockedInfo.isBlocked) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/blocked',
          (route) => false,
          arguments: blockedInfo,
        );
      }
    } catch (e) {
      debugPrint('Error checking blocked status: $e');
    } finally {
      _isCheckingBlockedStatus = false;
    }
  }
}

/// Widget that wraps screens and checks blocked status periodically
class BlockedStatusWrapper extends StatefulWidget {
  final Widget child;
  final Duration checkInterval;
  final bool checkOnResume;

  const BlockedStatusWrapper({
    super.key,
    required this.child,
    this.checkInterval = const Duration(minutes: 5),
    this.checkOnResume = true,
  });

  @override
  State<BlockedStatusWrapper> createState() => _BlockedStatusWrapperState();
}

class _BlockedStatusWrapperState extends State<BlockedStatusWrapper>
    with WidgetsBindingObserver {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    if (widget.checkOnResume) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void dispose() {
    if (widget.checkOnResume) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.checkOnResume) {
      _checkBlockedStatus();
    }
  }

  Future<void> _checkBlockedStatus() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final authProvider = context.read<AuthProvider>();

      // Only check if authenticated
      if (!authProvider.isAuthenticated) return;

      final blockedInfo = await authProvider.checkBlockedStatus();

      if (!mounted) return;

      if (blockedInfo.isBlocked) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/blocked',
          (route) => false,
          arguments: blockedInfo,
        );
      }
    } catch (e) {
      debugPrint('Error checking blocked status: $e');
    } finally {
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Global handler for HTTP 403 (Forbidden) responses
/// This should be used in Dio interceptors to detect blocked users
class BlockedUserHandler {
  static void handle403Response(
    BuildContext context,
    Map<String, dynamic>? responseData,
  ) {
    if (responseData == null) return;

    // Check if the 403 is due to blocked status
    if (responseData['is_blocked'] == true ||
        responseData['status'] == 'blocked') {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Force refresh blocked status
      authProvider.checkBlockedStatus().then((blockedInfo) {
        if (blockedInfo.isBlocked) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/blocked',
            (route) => false,
            arguments: blockedInfo,
          );
        }
      });
    }
  }
}
