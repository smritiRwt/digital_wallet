import 'dart:math' as math;
import 'package:flutter/material.dart';

class Particle {
  double x;
  double y;
  double size;
  double speedX;
  double speedY;
  double opacity;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.opacity,
    required this.color,
  });
}

class FloatingParticles extends StatefulWidget {
  final int count;
  final Widget? child;

  const FloatingParticles({
    super.key,
    this.count = 24,
    this.child,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();

  final List<Color> _palette = const [
    Color(0xFFA855F7), // violet
    Color(0xFF00F0FF), // cyan
    Color(0xFFFF2A85), // pink
    Color(0xFF6366F1), // indigo
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.count; i++) {
      _particles.add(
        Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 3.5 + 1.5,
          speedX: (_random.nextDouble() - 0.5) * 0.0006,
          speedY: -(_random.nextDouble() * 0.0008 + 0.0002),
          opacity: _random.nextDouble() * 0.5 + 0.15,
          color: _palette[_random.nextInt(_palette.length)],
        ),
      );
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
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
        // Update positions
        for (final p in _particles) {
          p.x += p.speedX;
          p.y += p.speedY;

          // Wrap boundaries
          if (p.x < 0) p.x = 1.0;
          if (p.x > 1) p.x = 0.0;
          if (p.y < 0) p.y = 1.0;
          if (p.y > 1) p.y = 0.0;
        }

        return CustomPaint(
          painter: _ParticlesPainter(particles: _particles),
          child: widget.child,
        );
      },
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<Particle> particles;

  _ParticlesPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final center = Offset(p.x * size.width, p.y * size.height);
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.8);

      canvas.drawCircle(center, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}
