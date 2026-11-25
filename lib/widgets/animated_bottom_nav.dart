import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class AnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onQuickPay;

  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onQuickPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Glassmorphic Dock Pill
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xCC0D0D22),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: _buildNavItem(
                          index: 0,
                          icon: Icons.dashboard_rounded,
                          label: 'Home',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: _buildNavItem(
                          index: 1,
                          icon: Icons.credit_card_rounded,
                          label: 'Cards',
                        ),
                      ),
                    ),
                    // Empty space for center floating quick pay button
                    const SizedBox(width: 48),
                    Expanded(
                      child: Center(
                        child: _buildNavItem(
                          index: 2,
                          icon: Icons.bar_chart_rounded,
                          label: 'Insights',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: _buildNavItem(
                          index: 3,
                          icon: Icons.history_rounded,
                          label: 'Activity',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Center Elevated Floating Pay Button
          Positioned(
            top: -18,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                onQuickPay();
              },
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: AppColors.neonGlow(
                    color: AppColors.vividViolet,
                    blurRadius: 24,
                    opacity: 0.6,
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.vividViolet.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            // Glowing underline dot
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonCyan,
                  boxShadow: AppColors.neonGlow(color: AppColors.neonCyan, blurRadius: 6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
