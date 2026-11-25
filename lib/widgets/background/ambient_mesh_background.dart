import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'floating_particles.dart';

class AmbientMeshBackground extends StatelessWidget {
  final Widget child;

  const AmbientMeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Solid Midnight Base
        Container(color: AppColors.background),

        // Deep Glowing Radial Orbs for Ambient Atmosphere
        Positioned(
          top: -120,
          right: -80,
          width: 380,
          height: 380,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.vividViolet.withValues(alpha: 0.28),
                  AppColors.vividViolet.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: 260,
          left: -140,
          width: 360,
          height: 360,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.neonCyan.withValues(alpha: 0.18),
                  AppColors.neonCyan.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 40,
          right: -100,
          width: 320,
          height: 320,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.neonPink.withValues(alpha: 0.15),
                  AppColors.neonPink.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // Interactive subtle drifting floating particle layer
        const Positioned.fill(
          child: FloatingParticles(count: 26),
        ),

        // Foreground contents
        Positioned.fill(child: child),
      ],
    );
  }
}
