import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/premium_button.dart';
import '../../../core/widgets/premium_text_field.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/providers/auth_provider.dart';

class LearningGoalsScreen extends StatefulWidget {
  const LearningGoalsScreen({Key? key}) : super(key: key);

  @override
  State<LearningGoalsScreen> createState() => _LearningGoalsScreenState();
}

class _LearningGoalsScreenState extends State<LearningGoalsScreen> {
  final TextEditingController _goalController = TextEditingController();
  final List<String> _suggestedGoals = [
    'Mathematics',
    'Python Programming',
    'World History',
    'Physics',
    'Language Arts',
    'AI & Machine Learning'
  ];

  void _continue() {
    if (_goalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tell us what you want to learn!')),
      );
      return;
    }
    
    // Save learning goal
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      final updatedUser = auth.user!.copyWith(learningGoal: _goalController.text.trim());
      auth.updateUserData(updatedUser);
    }
    
    context.go('/dashboard');
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          Positioned(
            top: -100,
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
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  Icon(
                    Icons.explore_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.secondary,
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'What do you want\nto learn today?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ).animate().slideY(begin: 0.2, end: 0).fadeIn(),
                  const SizedBox(height: AppSpacing.xl),
                  
                  PremiumTextField(
                    label: 'Your Goal',
                    hint: 'E.g., Quantum Physics, Python basics...',
                    prefixIcon: Icons.flag_rounded,
                    controller: _goalController,
                  ).animate().slideY(begin: 0.2, end: 0, delay: 100.ms).fadeIn(),
                  
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Suggested Topics',
                    style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppSpacing.md),
                  
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _suggestedGoals.map((goal) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _goalController.text = goal;
                          });
                        },
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          borderRadius: BorderRadius.circular(AppRadius.round),
                          child: Text(
                            goal,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _goalController.text == goal 
                                  ? Theme.of(context).colorScheme.primary 
                                  : null,
                              fontWeight: _goalController.text == goal ? FontWeight.bold : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate().fadeIn(delay: 300.ms),
                  
                  const Spacer(),
                  PremiumButton(
                    text: 'Start Learning',
                    onPressed: _continue,
                  ).animate().slideY(begin: 0.5, end: 0, delay: 400.ms).fadeIn(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
