import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:testora_flutter_ui/core/shell/main_shell.dart';
import 'package:testora_flutter_ui/features/auth/presentation/screens/auth_screens.dart';
import 'package:testora_flutter_ui/features/auth/presentation/splash_screen.dart';
import 'package:testora_flutter_ui/features/auth/providers/auth_providers.dart';
import 'package:testora_flutter_ui/features/exams/presentation/screens/bookmarks_screen.dart';
import 'package:testora_flutter_ui/features/exams/presentation/screens/exam_details_screen.dart';
import 'package:testora_flutter_ui/features/exams/presentation/screens/exams_screen.dart';
import 'package:testora_flutter_ui/features/exams/presentation/screens/mock_exams_screen.dart';
import 'package:testora_flutter_ui/features/home/presentation/screens/home_screen.dart';
import 'package:testora_flutter_ui/features/profile/presentation/screens/profile_screen.dart';
import 'package:testora_flutter_ui/features/payment/presentation/screens/payment_screen.dart';
import 'package:testora_flutter_ui/features/payment/presentation/screens/payment_checkout_screen.dart';
import 'package:testora_flutter_ui/features/progress/presentation/screens/progress_screen.dart';
import 'package:testora_flutter_ui/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:testora_flutter_ui/features/quiz/presentation/screens/quiz_setup_screen.dart';
import 'package:testora_flutter_ui/features/quiz/presentation/screens/result_screen.dart';
import 'package:testora_flutter_ui/features/quiz/presentation/screens/solution_screen.dart';

abstract final class Routes {
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const register = 'register';
  static const forgotPassword = 'forgot-password';
  static const home = 'home';
  static const categories = 'categories';
  static const exams = 'exams';
  static const progress = 'progress';
  static const payment = 'payment';
  static const paymentCheckout = 'payment-checkout';
  static const profile = 'profile';
  static const examDetails = 'exam-details';
  static const quizSetup = 'quiz-setup';
  static const quiz = 'quiz';
  static const result = 'result';
  static const solution = 'solution';
  static const mockExams = 'mock-exams';
  static const bookmarks = 'bookmarks';
  static const settings = 'settings';
  static const notifications = 'notifications';
  static const achievements = 'achievements';
  static const history = 'history';
}

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    redirect: (context, state) {
      final loc = state.matchedLocation;
      final onSplash = loc == '/splash';
      final onOnboarding = loc == '/onboarding';
      final onAuth = loc == '/login' || loc == '/register' || loc == '/forgot';

      // Still hydrating auth → hold on splash
      if (auth.isLoading) {
        return onSplash ? null : '/splash';
      }

      final loggedIn = auth.isLoggedIn;

      // Not logged in
      if (!loggedIn) {
        if (onSplash) return '/onboarding';
        if (onOnboarding || onAuth) return null;
        return '/login';
      }

      // Logged in
      if (onSplash || onOnboarding || onAuth) return '/home';
      return null;
    },
    errorBuilder: (context, state) => _RouteErrorScreen(error: state.error),

    routes: [
      GoRoute(
        path: '/splash',
        name: Routes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: Routes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: Routes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: Routes.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot',
        name: Routes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder:
            (context, state, navigationShell) =>
                MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: Routes.home,
                builder: (_, _) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/exams',
                name: Routes.exams,
                builder: (_, _) => const ExamsScreen(),
                routes: [
                  GoRoute(
                    path: ':examId',
                    name: Routes.examDetails,
                    builder:
                        (_, state) => ExamDetailsScreen(
                          examId: state.pathParameters['examId']!,
                        ),
                    routes: [
                      GoRoute(
                        path: 'setup',
                        name: Routes.quizSetup,
                        parentNavigatorKey: rootKey,
                        builder:
                            (_, state) => QuizSetupScreen(
                              subjectId: state.pathParameters['examId']!,
                            ),
                      ),
                      GoRoute(
                        path: 'quiz',
                        name: Routes.quiz,
                        parentNavigatorKey: rootKey,
                        builder:
                            (_, state) => QuizScreen(
                              examId: state.pathParameters['examId']!,
                            ),
                      ),
                      GoRoute(
                        path: 'result/:attemptId',
                        name: Routes.result,
                        parentNavigatorKey: rootKey,
                        builder:
                            (_, state) => ResultScreen(
                              examId: state.pathParameters['examId']!,
                              attemptId: state.pathParameters['attemptId']!,
                            ),
                      ),
                      GoRoute(
                        path: 'solution/:attemptId',
                        name: Routes.solution,
                        parentNavigatorKey: rootKey,
                        builder:
                            (_, state) => SolutionScreen(
                              examId: state.pathParameters['examId']!,
                              attemptId: state.pathParameters['attemptId']!,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: '/mock-exams',
                name: Routes.mockExams,
                builder: (_, _) => const MockExamsScreen(),
              ),
              GoRoute(
                path: '/categories',
                name: Routes.categories,
                builder: (_, _) => const CategoriesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                name: Routes.progress,
                builder: (_, _) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/payment',
                name: Routes.payment,
                builder: (_, _) => const PaymentScreen(),
                routes: [
                  GoRoute(
                    path: ':packageId',
                    name: Routes.paymentCheckout,
                    parentNavigatorKey: rootKey,
                    builder:
                        (_, state) => PaymentCheckoutScreen(
                          packageId: state.pathParameters['packageId']!,
                        ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    name: Routes.settings,
                    builder: (_, _) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    name: Routes.notifications,
                    builder: (_, _) => const NotificationsScreen(),
                  ),
                  GoRoute(
                    path: 'achievements',
                    name: Routes.achievements,
                    builder: (_, _) => const AchievementsScreen(),
                  ),
                  GoRoute(
                    path: 'history',
                    name: Routes.history,
                    builder: (_, _) => const HistoryScreen(),
                  ),
                  GoRoute(
                    path: 'bookmarks',
                    name: Routes.bookmarks,
                    builder: (_, _) => const BookmarksScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen({this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_off_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'This page does not exist.',
              style: theme.textTheme.titleMedium,
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    );
  }
}
