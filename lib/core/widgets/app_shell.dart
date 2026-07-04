import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          boxShadow: AppShadows.medium,
          border: Border(top: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.divider)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.home_rounded, 'Home', '/dashboard'),
                _buildNavItem(context, Icons.menu_book_rounded, 'Lessons', '/lessons'),
                
                // Floating Action Button Style for AI Chat
                GestureDetector(
                  onTap: () => context.go('/ai_chat'),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.glow,
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds),
                ),
                
                _buildNavItem(context, Icons.camera_alt_rounded, 'Scan', '/camera'),
                _buildNavItem(context, Icons.person_rounded, 'Profile', '/profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, String route) {
    final location = GoRouterState.of(context).uri.toString();
    final isSelected = location.startsWith(route);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final color = isSelected 
        ? AppColors.primary 
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

    return InkWell(
      onTap: () => context.go(route),
      borderRadius: AppRadius.smBorder,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
