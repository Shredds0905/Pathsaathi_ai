import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                  ),
                  Positioned(
                    bottom: -50,
                    right: -50,
                    child: Icon(Icons.person, size: 200, color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'profile_avatar',
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: AppShadows.glow,
                              border: Border.all(color: AppColors.primaryLight, width: 4),
                            ),
                            child: const Icon(Icons.person, size: 50, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          user?.name ?? 'Learner',
                          style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
                        ),
                        Text(
                          user?.email ?? 'learner@pathsaathi.ai',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('My Statistics', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(context, '12', 'Lessons', Icons.book, AppColors.primary)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _buildStatCard(context, '7', 'Day Streak', Icons.local_fire_department, AppColors.warning)),
                    ],
                  ).animate().slideY(begin: 0.2, end: 0, delay: 100.ms).fadeIn(),
                  const SizedBox(height: AppSpacing.xl),
                  
                  Text('Achievements', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  _buildAchievementTile(context, 'Fast Learner', 'Completed 5 lessons in a day', Icons.bolt, true),
                  _buildAchievementTile(context, 'Quiz Master', 'Scored 100% on 3 quizzes', Icons.emoji_events, false),
                  _buildAchievementTile(context, 'Night Owl', 'Studied after 10 PM', Icons.nights_stay, true),
                  
                  const SizedBox(height: AppSpacing.xxl),
                  GlassContainer(
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.accent),
                      title: const Text('Log Out', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                      onTap: () {
                        context.read<AuthProvider>().signOut();
                        context.go('/login');
                      },
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(BuildContext context, String title, String desc, IconData icon, bool unlocked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassContainer(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: unlocked ? AppColors.warning.withValues(alpha: 0.2) : AppColors.divider.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: unlocked ? AppColors.warning : AppColors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  Text(desc, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (unlocked)
              const Icon(Icons.check_circle, color: AppColors.secondary, size: 20)
            else
              const Icon(Icons.lock, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.2, end: 0, delay: 200.ms).fadeIn();
  }
}
