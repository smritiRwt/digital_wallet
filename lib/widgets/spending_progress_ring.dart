import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SpendingProgressRing extends StatefulWidget {
  final double shoppingPercent;
  final double techPercent;
  final double foodPercent;
  final double entertainmentPercent;
  final double totalSpent;

  const SpendingProgressRing({
    super.key,
    this.shoppingPercent = 0.38,
    this.techPercent = 0.32,
    this.foodPercent = 0.18,
    this.entertainmentPercent = 0.12,
    this.totalSpent = 3840.50,
  });

  @override
  State<SpendingProgressRing> createState() => _SpendingProgressRingState();
}

class _SpendingProgressRingState extends State<SpendingProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(190, 190),
          painter: _SpendingRingPainter(
            progress: _animation.value,
            shopping: widget.shoppingPercent,
            tech: widget.techPercent,
            food: widget.foodPercent,
            entertainment: widget.entertainmentPercent,
          ),
          child: SizedBox(
            width: 190,
            height: 190,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TOTAL SPENT',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${(widget.totalSpent * _animation.value).toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '-14% vs last mo',
                      style: TextStyle(
                        color: AppColors.neonGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SpendingRingPainter extends CustomPainter {
  final double progress;
  final double shopping;
  final double tech;
  final double food;
  final double entertainment;

  _SpendingRingPainter({
    required this.progress,
    required this.shopping,
    required this.tech,
    required this.food,
    required this.entertainment,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 14.0;
    const gap = 0.08; // gap between segments in radians

    // Background track ring
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final segments = [
      {'color': const Color(0xFFA855F7), 'ratio': shopping}, // Shopping (purple)
      {'color': const Color(0xFF00F0FF), 'ratio': tech},     // Tech (cyan)
      {'color': const Color(0xFFFFB800), 'ratio': food},     // Food (amber)
      {'color': const Color(0xFFFF2A85), 'ratio': entertainment}, // Ent (pink)
    ];

    double startAngle = -math.pi / 2;

    for (final seg in segments) {
      final color = seg['color'] as Color;
      final ratio = seg['ratio'] as double;
      final sweepAngle = (2 * math.pi * ratio - gap) * progress;

      if (sweepAngle > 0) {
        final arcPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        // Glow layer for active arc
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.35 * progress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          glowPaint,
        );

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          arcPaint,
        );
      }

      startAngle += (2 * math.pi * ratio);
    }
  }

  @override
  bool shouldRepaint(covariant _SpendingRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
