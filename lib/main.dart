import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/home/screens/main_screen.dart';
import 'features/home/providers/dashboard_provider.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/support/screens/support_screen.dart';
import 'features/leaderboard/providers/leaderboard_provider.dart';

import 'features/tasks/providers/task_provider.dart';
import 'features/tasks/screens/task_execution_screen.dart';
import 'models/task_model.dart';

import 'features/wallet/providers/wallet_provider.dart';
import 'features/wallet/screens/withdraw_screen.dart';

import 'features/plans/providers/plan_provider.dart';
import 'features/plans/screens/plans_screen.dart';

import 'features/team/providers/team_provider.dart';

import 'features/profile/providers/user_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        return null;
      },
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const MainScreen(),
        '/withdraw': (context) => const WithdrawScreen(),
        '/plans': (context) => const PlansScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/support': (context) => const SupportScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
