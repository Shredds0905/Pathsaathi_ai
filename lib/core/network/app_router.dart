import 'package:go_router/go_router.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/onboarding/screens/learning_goals_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/lessons/screens/lessons_screen.dart';
import '../../features/quizzes/screens/quiz_screen.dart';
import '../../features/ai_chat/screens/ai_chat_screen.dart';
import '../../features/camera/screens/camera_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../widgets/app_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/learning-goals',
      builder: (context, state) => const LearningGoalsScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/lessons',
          builder: (context, state) => const LessonsScreen(),
        ),
        GoRoute(
          path: '/ai_chat',
          builder: (context, state) => const AIChatScreen(),
        ),
        GoRoute(
          path: '/camera',
          builder: (context, state) => const CameraScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/quiz/:id',
      builder: (context, state) => QuizScreen(quizId: state.pathParameters['id']!),
    ),
  ],
);
