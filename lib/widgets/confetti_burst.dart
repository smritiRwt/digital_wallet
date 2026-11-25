import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiPiece {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double size;
  final double rotation;
  final double vRot;
  final Color color;
  final bool isCircle;

  ConfettiPiece({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.vRot,
    required this.color,
    required this.isCircle,
  });
}

class ConfettiBurst extends StatefulWidget {
  final int count;
  final Widget? child;

  const ConfettiBurst({
    super.key,
    this.count = 45,
    this.child,
  });

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiPiece> _pieces = [];
  final math.Random _random = math.Random();

  final List<Color> _palette = const [
    Color(0xFF00F0FF),
    Color(0xFFA855F7),
    Color(0xFFFF2A85),
    Color(0xFF10B981),
    Color(0xFFFFB800),
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    for (int i = 0; i < widget.count; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = _random.nextDouble() * 6 + 3;
      _pieces.add(
        ConfettiPiece(
          x: 0.5,
          y: 0.35,
          vx: math.cos(angle) * speed * 0.0018,
          vy: math.sin(angle) * speed * 0.0018 - 0.003,
          size: _random.nextDouble() * 6 + 5,
          rotation: _random.nextDouble() * 2 * math.pi,
          vRot: (_random.nextDouble() - 0.5) * 0.15,
          color: _palette[_random.nextInt(_palette.length)],
          isCircle: _random.nextBool(),
        ),
      );
    }

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
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return CustomPaint(
          painter: _ConfettiPainter(
            pieces: _pieces,
            progress: t,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiPiece> pieces;
  final double progress;

  _ConfettiPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in pieces) {
      // Apply simulated gravity and air resistance
      final currentX = (p.x + p.vx * progress * 40) * size.width;
      final currentY = (p.y + p.vy * progress * 40 + 0.5 * 0.006 * progress * progress * 80) * size.height;
      final currentRot = p.rotation + p.vRot * progress * 30;

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRot);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
