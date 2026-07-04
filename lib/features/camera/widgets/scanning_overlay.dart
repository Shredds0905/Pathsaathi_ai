import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';

class ScanningOverlay extends StatelessWidget {
  final bool isScanning;
  final double confidence; // 0.0 to 1.0

  const ScanningOverlay({
    Key? key,
    this.isScanning = true,
    this.confidence = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Darkened background with clear center
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
              Center(
                child: Container(
                  width: 300,
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: AppRadius.mdBorder,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Corner Brackets
        Center(
          child: SizedBox(
            width: 300,
            height: 400,
            child: Stack(
              children: [
                _buildCorner(Alignment.topLeft),
                _buildCorner(Alignment.topRight),
                _buildCorner(Alignment.bottomLeft),
                _buildCorner(Alignment.bottomRight),
                
                // Scanning Line Animation
                if (isScanning)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                     .slideY(begin: 0, end: 100, duration: 2.seconds, curve: Curves.easeInOut),
                  ),
              ],
            ),
          ),
        ),

        // Confidence Score Badge
        if (confidence > 0)
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(AppRadius.round),
                  border: Border.all(color: _getConfidenceColor(confidence)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      confidence > 0.8 ? Icons.check_circle : Icons.warning_amber,
                      color: _getConfidenceColor(confidence),
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${(confidence * 100).toInt()}% Confidence',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
            ),
          ),
      ],
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: _getBorder(alignment),
        ),
      ),
    );
  }

  Border _getBorder(Alignment alignment) {
    const side = BorderSide(color: AppColors.primary, width: 4);
    if (alignment == Alignment.topLeft) return const Border(top: side, left: side);
    if (alignment == Alignment.topRight) return const Border(top: side, right: side);
    if (alignment == Alignment.bottomLeft) return const Border(bottom: side, left: side);
    return const Border(bottom: side, right: side);
  }

  Color _getConfidenceColor(double conf) {
    if (conf > 0.8) return AppColors.secondary;
    if (conf > 0.5) return AppColors.warning;
    return AppColors.accent;
  }
}

