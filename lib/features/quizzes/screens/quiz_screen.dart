import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/premium_button.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../providers/quiz_provider.dart';
import '../../../models/quiz_model.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;
  const QuizScreen({Key? key, required this.quizId}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late ConfettiController _confettiController;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().startQuiz(SampleQuizzes.all.first);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onOptionSelected(int index) {
    context.read<QuizProvider>().selectAnswer(index);
  }

  void _submitAnswer() {
    final provider = context.read<QuizProvider>();
    provider.submitAnswer();
    
    final isQuizComplete = provider.state.toString().contains('completed') || provider.progressFraction >= 1.0;
    
    if (isQuizComplete) {
      if (provider.score >= (provider.currentQuiz!.questions.length / 2)) {
        _confettiController.play();
      }
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Time!'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Consumer<QuizProvider>(
            builder: (context, provider, child) {
              final isQuizComplete = provider.state.toString().contains('completed') || provider.progressFraction >= 1.0;
              
              if (provider.currentQuiz == null) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (isQuizComplete) {
                return _buildResultsScreen(provider);
              }

              return Column(
                children: [
                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (provider.currentQuestionIndex + 1) / provider.currentQuiz!.questions.length,
                            backgroundColor: AppColors.divider,
                            color: AppColors.secondary,
                            minHeight: 8,
                            borderRadius: AppRadius.smBorder,
                          ).animate().scaleX(alignment: Alignment.centerLeft),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          '${provider.currentQuestionIndex + 1}/${provider.currentQuiz!.questions.length}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                  
                  // Question PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(), // Disable swipe
                      itemCount: provider.currentQuiz!.questions.length,
                      itemBuilder: (context, index) {
                        final question = provider.currentQuiz!.questions[index];
                        return _buildQuestionCard(question, provider);
                      },
                    ),
                  ),

                  // Bottom Button
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: PremiumButton(
                      text: provider.selectedAnswerIndex == null ? 'Select an answer' : 'Submit',
                      onPressed: provider.selectedAnswerIndex == null ? () {} : _submitAnswer,
                      isSecondary: provider.selectedAnswerIndex == null,
                    ).animate().slideY(begin: 1, end: 0),
                  ),
                ],
              );
            },
          ),
          
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.warning],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(question, QuizProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question.question,
              style: Theme.of(context).textTheme.titleLarge,
            ).animate().fadeIn(),
            const SizedBox(height: AppSpacing.xl),
            ...List.generate(question.options.length, (i) {
              final isSelected = provider.selectedAnswerIndex == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GestureDetector(
                  onTap: () => _onOptionSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.5) : Theme.of(context).colorScheme.surface,
                      borderRadius: AppRadius.mdBorder,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? AppShadows.glow : AppShadows.light,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            question.options[i],
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().slideX(begin: 0.2, end: 0, delay: Duration(milliseconds: i * 100));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen(QuizProvider provider) {
    final passed = provider.score >= (provider.currentQuiz!.questions.length / 2);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: passed ? AppColors.secondary.withValues(alpha: 0.1) : AppColors.accent.withValues(alpha: 0.1),
              ),
              child: Icon(
                passed ? Icons.emoji_events : Icons.refresh,
                size: 80,
                color: passed ? AppColors.warning : AppColors.accent,
              ),
            ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
            const SizedBox(height: AppSpacing.xl),
            Text(
              passed ? 'Congratulations!' : 'Keep Practicing!',
              style: Theme.of(context).textTheme.displaySmall,
            ).animate().slideY().fadeIn(),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You scored ${provider.score} out of ${provider.currentQuiz!.questions.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ).animate().slideY().fadeIn(delay: 200.ms),
            if (passed) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: Text('+${provider.xpEarned} XP Earned!', style: const TextStyle(color: AppColors.secondaryDark, fontWeight: FontWeight.bold)),
              ).animate().scale(delay: 400.ms),
            ],
            const SizedBox(height: AppSpacing.xxl),
            PremiumButton(
              text: 'Back to Lessons',
              onPressed: () => Navigator.of(context).pop(),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
