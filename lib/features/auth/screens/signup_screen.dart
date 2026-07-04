import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/premium_button.dart';
import '../../../core/widgets/premium_text_field.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _selectedRole = 'student';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    
    final success = await auth.signUpWithEmail(email: 
      _emailController.text, password: 
      _passwordController.text, name: 
      _nameController.text, role: 
      _selectedRole,
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.go('/learning-goals');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Animated Background
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x2000C9B1),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4.seconds),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium,
                      ).animate().slideY(begin: 0.2, end: 0).fadeIn(),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Join us and start your journey',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).animate().slideY(begin: 0.2, end: 0, delay: 100.ms).fadeIn(),
                      const SizedBox(height: AppSpacing.xxl),
                      
                      GlassContainer(
                        child: Column(
                          children: [
                            PremiumTextField(
                              label: 'Full Name',
                              hint: 'Enter your name',
                              prefixIcon: Icons.person_outline,
                              controller: _nameController,
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: AppSpacing.lg),
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
                              hint: 'Create a password',
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                              controller: _passwordController,
                              validator: (val) => val == null || val.length < 6 ? 'Min 6 characters' : null,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            
                            // Role Selector
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('I am a...', style: Theme.of(context).textTheme.labelLarge),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    _buildRoleChip('Student', 'student'),
                                    const SizedBox(width: AppSpacing.sm),
                                    _buildRoleChip('Parent', 'parent'),
                                    const SizedBox(width: AppSpacing.sm),
                                    _buildRoleChip('Teacher', 'teacher'),
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: AppSpacing.xl),
                            PremiumButton(
                              text: 'Sign Up',
                              isLoading: _isLoading,
                              onPressed: _signup,
                            ),
                          ],
                        ),
                      ).animate().slideY(begin: 0.1, end: 0, delay: 200.ms).fadeIn(),
                      const SizedBox(height: AppSpacing.xl),
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

  Widget _buildRoleChip(String label, String value) {
    final isSelected = _selectedRole == value;
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
            borderRadius: AppRadius.smBorder,
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : AppColors.divider,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
