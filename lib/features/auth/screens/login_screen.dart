import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/premium_button.dart';
import '../../../core/widgets/premium_text_field.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    
    final success = await auth.signInWithEmail(email: 
      _emailController.text, password: 
      _passwordController.text,
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.go('/learning-goals');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please check credentials.')),
        );
      }
    }
  }

  void _googleLogin() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.go('/learning-goals');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          Positioned(
            top: -150,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x206C63FF),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 3.seconds),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium,
                      ).animate().slideY(begin: 0.2, end: 0).fadeIn(),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Sign in to continue your learning journey',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).animate().slideY(begin: 0.2, end: 0, delay: 100.ms).fadeIn(),
                      const SizedBox(height: AppSpacing.xxl),
                      
                      GlassContainer(
                        child: Column(
                          children: [
                            PremiumTextField(
                              label: 'Email',
                              hint: 'Enter your email',
                              prefixIcon: Icons.email_outlined,
                              controller: _emailController,
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            PremiumTextField(
                              label: 'Password',
                              hint: 'Enter your password',
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                              controller: _passwordController,
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            PremiumButton(
                              text: 'Sign In',
                              isLoading: _isLoading,
                              onPressed: _login,
                            ),
                          ],
                        ),
                      ).animate().slideY(begin: 0.1, end: 0, delay: 200.ms).fadeIn(),
                      
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.divider)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            child: Text('OR', style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          Expanded(child: Divider(color: AppColors.divider)),
                        ],
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: AppSpacing.xl),
                      
                      PremiumButton(
                        text: 'Continue with Google',
                        icon: Icons.g_mobiledata, // Placeholder for Google Icon
                        isSecondary: true,
                        isLoading: _isLoading,
                        onPressed: _googleLogin,
                      ).animate().slideY(begin: 0.1, end: 0, delay: 400.ms).fadeIn(),
                      
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('New to PathSaathi? ', style: Theme.of(context).textTheme.bodyMedium),
                          GestureDetector(
                            onTap: () => context.push('/signup'),
                            child: Text(
                              'Sign Up',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 500.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
