import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/design_system.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool isDark;

  const GlassContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _isDark = isDark || theme.brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? AppRadius.lgBorder,
        boxShadow: AppShadows.light,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? AppRadius.lgBorder,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: _isDark
                  ? AppColors.glassGradientDark
                  : AppColors.glassGradientLight,
              borderRadius: borderRadius ?? AppRadius.lgBorder,
              border: Border.all(
                color: _isDark ? Colors.white12 : Colors.white60,
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
