import 'package:flutter/material.dart';

class AppColors {
  // Midnight Backgrounds
  static const Color background = Color(0xFF070712);
  static const Color surface = Color(0xFF0F0F26);
  static const Color surfaceLight = Color(0xFF171738);
  static const Color surfaceGlass = Color(0x18FFFFFF);
  static const Color surfaceGlassHigh = Color(0x28FFFFFF);
  static const Color borderGlass = Color(0x25FFFFFF);
  static const Color borderGlassActive = Color(0x60A855F7);

  // Neon & Electric Accents
  static const Color electricPurple = Color(0xFF8B5CF6);
  static const Color vividViolet = Color(0xFFA855F7);
  static const Color neonPink = Color(0xFFFF2A85);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonBlue = Color(0xFF3B82F6);
  static const Color neonGreen = Color(0xFF10B981);
  static const Color neonEmerald = Color(0xFF00FF9D);
  static const Color neonAmber = Color(0xFFFFB800);
  static const Color neonRed = Color(0xFFFF3366);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF475569);

  // Status & Alerts
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanBlueGradient = LinearGradient(
    colors: [Color(0xFF00F0FF), Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleVioletGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenEmeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF00FF9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1B1B38), Color(0xFF0F0F23)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x28FFFFFF), Color(0x0AFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient frozenCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow Shadows
  static List<BoxShadow> neonGlow({
    Color color = AppColors.vividViolet,
    double blurRadius = 24.0,
    double spreadRadius = 0.0,
    double opacity = 0.45,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
      BoxShadow(
        color: color.withValues(alpha: opacity * 0.5),
        blurRadius: blurRadius * 1.8,
        spreadRadius: spreadRadius * 0.5,
      ),
    ];
  }

  static List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.45),
      blurRadius: 28,
      offset: const Offset(0, 14),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.05),
      blurRadius: 1,
      offset: const Offset(0, 1),
    ),
  ];
}
