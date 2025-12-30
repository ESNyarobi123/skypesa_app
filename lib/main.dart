import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firebase_notification_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/blocked_screen.dart';
import 'models/blocked_info_model.dart';
import 'features/home/screens/main_screen.dart';
import 'features/home/providers/dashboard_provider.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/support/screens/support_screen.dart';
import 'features/support/screens/ticket_detail_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/leaderboard/providers/leaderboard_provider.dart';

import 'features/tasks/providers/task_provider.dart';
import 'features/tasks/screens/task_execution_screen.dart';
import 'models/task_model.dart';

import 'features/wallet/providers/wallet_provider.dart';
import 'features/wallet/screens/withdraw_screen.dart';
import 'features/wallet/screens/withdrawal_history_screen.dart';

import 'features/plans/providers/plan_provider.dart';
import 'features/plans/screens/plans_screen.dart';

import 'features/team/providers/team_provider.dart';

import 'features/profile/providers/user_provider.dart';

// Global key for navigation from notification handlers
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Notification Service
  final notificationService = FirebaseNotificationService();
  await notificationService.initialize();

  // Save FCM token for sending to backend
  await notificationService.saveToken();

  // Subscribe to general announcements topic
  await notificationService.subscribeToTopic('announcements');

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => PlanProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
      ],
      child: MyApp(notificationService: notificationService),
    ),
  );
}

class MyApp extends StatefulWidget {
  final FirebaseNotificationService notificationService;

  const MyApp({super.key, required this.notificationService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupNotificationListeners();
  }

  void _setupNotificationListeners() {
    // Listen for notification taps
    widget.notificationService.onNotificationTap.listen((message) {
      _handleNotificationNavigation(message.data);
    });
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Navigate based on notification data
    final type = data['type'] as String?;

    switch (type) {
      case 'withdrawal':
        navigatorKey.currentState?.pushNamed('/withdrawal-history');
        break;
      case 'task':
        navigatorKey.currentState?.pushNamed('/dashboard');
        break;
      case 'announcement':
        navigatorKey.currentState?.pushNamed('/notifications');
        break;
      default:
        navigatorKey.currentState?.pushNamed('/notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'SKYpesa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/task-execution') {
          final task = settings.arguments as Task;
          return MaterialPageRoute(
            builder: (context) => TaskExecutionScreen(task: task),
          );
        }
        if (settings.name == '/ticket-detail') {
          final ticketNumber = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) =>
                TicketDetailScreen(ticketNumber: ticketNumber),
          );
        }
        if (settings.name == '/blocked') {
          final blockedInfo = settings.arguments as BlockedInfo;
          return MaterialPageRoute(
            builder: (context) => BlockedScreen(
              blockedInfo: blockedInfo,
              onRefresh: () async {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                final newInfo = await authProvider.checkBlockedStatus();
                if (!newInfo.isBlocked) {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                }
              },
              onLogout: () {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                authProvider.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const MainScreen(),
        '/withdraw': (context) => const WithdrawScreen(),
        '/withdrawal-history': (context) => const WithdrawalHistoryScreen(),
        '/plans': (context) => const PlansScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/support': (context) => const SupportScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}
