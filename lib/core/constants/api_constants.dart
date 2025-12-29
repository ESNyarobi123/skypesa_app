class ApiConstants {
  static const String baseUrl = 'https://skypesa.hosting.hollyn.online/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';

  // User
  static const String profile = '/user/profile';
  static const String dashboard = '/user/dashboard';
  static const String updateAvatar = '/user/avatar';
  static const String changePassword = '/user/password';
  static const String blockedInfo = '/user/blocked-info';

  // Tasks
  static const String tasks = '/tasks';
  static const String activeTask = '/tasks/activity/current';
  static const String taskHistory = '/tasks/history/completed';
  static const String cancelTask = '/tasks/cancel';
  static String startTask(dynamic id) => '/tasks/$id/start';
  static String taskStatus(dynamic id) => '/tasks/$id/status';
  static String completeTask(dynamic id) => '/tasks/$id/complete';

  // Wallet
  static const String wallet = '/wallet';
  static const String transactions = '/wallet/transactions';
  static const String walletEarnings = '/wallet/earnings';

  // Withdrawals
  static const String withdrawals = '/withdrawals';
  static const String withdrawalInfo = '/withdrawals/info';

  // Plans & Subscriptions
  static const String plans = '/plans';
  static const String currentSubscription = '/subscriptions/current';
  static const String subscriptionHistory = '/subscriptions/history';
  static String paySubscription(dynamic id) => '/subscriptions/pay/$id';
  static String paymentStatus(String orderId) =>
      '/subscriptions/payment-status/$orderId';

  // Referrals
  static const String referrals = '/referrals';
  static const String referralUsers = '/referrals/users';

  // Leaderboard
  static const String leaderboard = '/leaderboard';
  static const String leaderboardReferrers = '/leaderboard/referrers';
  static const String leaderboardTasks = '/leaderboard/tasks';

  // Support
  static const String supportContact = '/support/contact';
  static const String supportFaq = '/support/faq';
  static const String supportTickets = '/support/tickets';
  static const String bugReport = '/support/bug-report';
}
