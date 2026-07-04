import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Animation
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x156C63FF),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 5.seconds),
          ),
          
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(user?.name ?? 'Learner'),
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildStreakCard(user?.currentStreak ?? 0),
                      const SizedBox(height: AppSpacing.xl),
                      Text("Today's Goal", style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: AppSpacing.md),
                      _buildProgressRing(user?.levelProgress ?? 0.0, user?.totalXp ?? 0),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Continue Learning', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: AppSpacing.md),
                      _buildContinueLearningCard(user?.learningGoal ?? ''),
                      const SizedBox(height: AppSpacing.xl),
                      Text('AI Recommendations', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: AppSpacing.md),
                      _buildAIRecommendationCard(user?.learningGoal ?? ''),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Weekly Statistics', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: AppSpacing.md),
                      _buildStatsGraph(),
                      const SizedBox(height: 100), // Bottom padding for nav
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(String name) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        title: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning,',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ).animate().fadeIn(),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().slideX(begin: -0.2, end: 0).fadeIn(),
              ],
            ),
            const Spacer(),
            Hero(
              tag: 'profile_avatar',
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
            ).animate().scale(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(int streak) {
    return GlassContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: AppRadius.smBorder,
                ),
                child: const Icon(Icons.local_fire_department, color: AppColors.warning),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak > 0 ? '$streak Day Streak!' : 'Start Your Streak!',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    streak > 0 ? 'You are on a roll 🔥' : 'Learn something today',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0, delay: 100.ms).fadeIn();
  }

  Widget _buildProgressRing(double progress, int xp) {
    return Row(
      children: [
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 8,
                        backgroundColor: AppColors.divider,
                        color: AppColors.primary,
                      ).animate().scale(delay: 400.ms),
                      Text(
                        '${(progress.clamp(0.0, 1.0) * 100).toInt()}%',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      ).animate().fadeIn(delay: 600.ms),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily XP Goal', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text('$xp / 500 XP', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: AppSpacing.sm),
                      LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.divider,
                        color: AppColors.secondary,
                        borderRadius: AppRadius.smBorder,
                      ).animate().slideX(begin: -1, end: 0, delay: 500.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().slideY(begin: 0.2, end: 0, delay: 200.ms).fadeIn();
  }

  Widget _buildContinueLearningCard(String learningGoal) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppRadius.lgBorder,
          boxShadow: AppShadows.glow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: AppRadius.smBorder,
                    ),
                    child: const Text('LEARNING', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    learningGoal.isNotEmpty ? learningGoal : 'Physics: Quantum Mechanics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Row(
                    children: [
                      Icon(Icons.play_circle_fill, color: Colors.white),
                      SizedBox(width: AppSpacing.sm),
                      Text('Resume Lesson', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: AppRadius.mdBorder,
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white, size: 40),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.2, end: 0, delay: 300.ms).fadeIn();
  }

  Widget _buildAIRecommendationCard(String learningGoal) {
    return GlassContainer(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.secondaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome, color: AppColors.secondaryDark),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recommended for you', style: Theme.of(context).textTheme.labelLarge),
                    Text(
                      learningGoal.isNotEmpty
                          ? 'Based on your goal: $learningGoal'
                          : 'Based on recent activity', 
                      style: Theme.of(context).textTheme.bodySmall
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppRadius.mdBorder,
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.calculate, color: AppColors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    learningGoal.isNotEmpty ? 'Practice: $learningGoal' : 'Calculus: Derivatives Practice', 
                    style: Theme.of(context).textTheme.labelLarge
                  ),
                ),
                const Icon(Icons.arrow_forward, size: 20, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0, delay: 400.ms).fadeIn();
  }

  Widget _buildStatsGraph() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.light,
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Text(days[value.toInt()], style: const TextStyle(color: AppColors.textSecondary, fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3),
                FlSpot(1, 1),
                FlSpot(2, 4),
                FlSpot(3, 2),
                FlSpot(4, 5),
                FlSpot(5, 3),
                FlSpot(6, 4),
              ],
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.2, end: 0, delay: 500.ms).fadeIn();
  }
}
