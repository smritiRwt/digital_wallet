import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final String prefix;
  final int fractionDigits;
  final Duration duration;
  final Curve curve;
  final bool isHidden;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '\$',
    this.fractionDigits = 2,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
    this.isHidden = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHidden) {
      return Text(
        '$prefix ••••••••',
        style: style?.copyWith(letterSpacing: 2.0),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedVal, child) {
        final formatter = NumberFormat.currency(
          symbol: prefix,
          decimalDigits: fractionDigits,
        );
        return Text(
          formatter.format(animatedVal),
          style: style,
        );
      },
    );
  }
}
