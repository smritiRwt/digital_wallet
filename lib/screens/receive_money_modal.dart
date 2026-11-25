import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';

class ReceiveMoneyModal extends StatefulWidget {
  const ReceiveMoneyModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReceiveMoneyModal(),
    );
  }

  @override
  State<ReceiveMoneyModal> createState() => _ReceiveMoneyModalState();
}

class _ReceiveMoneyModalState extends State<ReceiveMoneyModal> {
  final String _upiAddress = 'alexander.vane@nexuspay';
  bool _copied = false;

  void _copyAddress() {
    Clipboard.setData(ClipboardData(text: _upiAddress));
    HapticFeedback.selectionClick();
    setState(() => _copied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('UPI / Wallet Address copied!'),
        backgroundColor: Color(0xFF1E1B4B),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
      decoration: BoxDecoration(
        color: const Color(0xF00D0D20),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Receive Money & QR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Glowing QR Code Display Container
          Container(
            width: 210,
            height: 210,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppColors.neonGlow(
                color: AppColors.neonCyan,
                blurRadius: 28,
                opacity: 0.35,
              ),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(180, 180),
                  painter: _QrCodePainter(),
                ),
                Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF070712),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.neonCyan, width: 2),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: AppColors.neonCyan,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // User Handle / Address Box
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.qr_code_scanner_rounded, color: AppColors.neonCyan, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nexus Pay ID',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      Text(
                        _upiAddress,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _copyAddress,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _copied
                          ? AppColors.neonEmerald.withValues(alpha: 0.2)
                          : AppColors.vividViolet.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _copied ? AppColors.neonEmerald : AppColors.vividViolet,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _copied ? Icons.check_rounded : Icons.copy_rounded,
                          size: 14,
                          color: _copied ? AppColors.neonEmerald : AppColors.vividViolet,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _copied ? 'Copied' : 'Copy',
                          style: TextStyle(
                            color: _copied ? AppColors.neonEmerald : AppColors.vividViolet,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          NeonButton(
            text: 'Share Payment Link',
            icon: Icons.share_rounded,
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment link shared to clipboard!'),
                  backgroundColor: Color(0xFF1E1B4B),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF070712)
      ..style = PaintingStyle.fill;

    const blockSize = 6.0;
    final cols = (size.width / blockSize).floor();
    final rows = (size.height / blockSize).floor();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Corner markers
        final isCorner = (r < 8 && c < 8) || (r < 8 && c >= cols - 8) || (r >= rows - 8 && c < 8);
        final isCenter = (r >= 11 && r <= 17 && c >= 11 && c <= 17);

        if (isCenter) continue;

        if (isCorner) {
          final isBorder = (r == 0 || r == 6 || c == 0 || c == 6) && (r <= 6 && c <= 6);
          final isTopRightBorder = (r == 0 || r == 6 || c == cols - 7 || c == cols - 1) && (r <= 6 && c >= cols - 7);
          final isBottomLeftBorder = (r == rows - 7 || r == rows - 1 || c == 0 || c == 6) && (r >= rows - 7 && c <= 6);

          final isInnerDot = (r >= 2 && r <= 4 && c >= 2 && c <= 4) ||
              (r >= 2 && r <= 4 && c >= cols - 5 && c <= cols - 3) ||
              (r >= rows - 5 && r <= rows - 3 && c >= 2 && c <= 4);

          if (isBorder || isTopRightBorder || isBottomLeftBorder || isInnerDot) {
            canvas.drawRect(
              Rect.fromLTWH(c * blockSize, r * blockSize, blockSize - 0.5, blockSize - 0.5),
              paint,
            );
          }
        } else {
          // Synthetic pseudo random QR pattern
          if ((r * 7 + c * 13 + (r * c)) % 3 == 0) {
            canvas.drawRect(
              Rect.fromLTWH(c * blockSize, r * blockSize, blockSize - 0.5, blockSize - 0.5),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
