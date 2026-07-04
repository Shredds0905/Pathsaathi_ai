import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/premium_button.dart';
import '../../../core/widgets/glass_container.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'AI-Powered\nLearning',
      description: 'Your personal AI tutor that adapts to your learning style and pace.',
      icon: Icons.psychology,
      color: AppColors.primary,
    ),
    _OnboardingData(
      title: 'Interactive\nQuizzes',
      description: 'Test your knowledge with gamified quizzes and earn real-time rewards.',
      icon: Icons.quiz,
      color: AppColors.secondary,
    ),
    _OnboardingData(
      title: 'Multilingual\nSupport',
      description: 'Learn in your native language. We break down the language barrier.',
      icon: Icons.language,
      color: AppColors.accent,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pages[_currentIndex].color.withValues(alpha: 0.2),
              ),
            ).animate(target: _currentIndex.toDouble()).scale(
                  duration: 600.ms,
                  curve: Curves.easeInOut,
                ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GlassContainer(
                              padding: const EdgeInsets.all(AppSpacing.xxl),
                              borderRadius: BorderRadius.circular(AppRadius.round),
                              child: Icon(
                                _pages[index].icon,
                                size: 100,
                                color: _pages[index].color,
                              ),
                            ).animate().scale(duration: 500.ms, delay: 200.ms),
                            const SizedBox(height: AppSpacing.xxl),
                            Text(
                              _pages[index].title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium,
                            ).animate().slideY(begin: 0.2, end: 0).fadeIn(),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _pages[index].description,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ).animate().slideY(begin: 0.2, end: 0, delay: 100.ms).fadeIn(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      SmoothPageIndicator(
                        controller: _controller,
                        count: _pages.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: _pages[_currentIndex].color,
                          dotColor: AppColors.divider,
                          dotHeight: 8,
                          dotWidth: 8,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          if (_currentIndex > 0)
                            Expanded(
                              child: PremiumButton(
                                text: 'Back',
                                isSecondary: true,
                                onPressed: () {
                                  _controller.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ).animate().fadeIn(),
                          if (_currentIndex > 0) const SizedBox(width: AppSpacing.md),
                          Expanded(
                            flex: 2,
                            child: PremiumButton(
                              text: _currentIndex == _pages.length - 1 ? 'Get Started' : 'Next',
                              onPressed: () {
                                if (_currentIndex == _pages.length - 1) {
                                  context.go('/login');
                                } else {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

