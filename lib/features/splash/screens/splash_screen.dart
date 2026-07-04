import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/design_system.dart';
import '../../auth/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.status == AuthStatus.authenticated) {
      context.go('/dashboard');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.glow,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 60,
                  color: AppColors.primary,
                ),
              )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.easeOutBack)
                  .fadeIn(),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'PathSaathi AI',
                style: AppTypography.getDarkTextTheme().displayMedium,
              )
                  .animate()
                  .slideY(begin: 0.5, end: 0, duration: 600.ms, delay: 200.ms)
                  .fadeIn(delay: 200.ms),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Every Learner Deserves a Guide',
                style: AppTypography.getDarkTextTheme().bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
              )
                  .animate()
                  .slideY(begin: 0.5, end: 0, duration: 600.ms, delay: 400.ms)
                  .fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
