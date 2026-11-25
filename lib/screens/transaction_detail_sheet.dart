import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_item.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';

class TransactionDetailSheet extends StatelessWidget {
  final TransactionItem item;

  const TransactionDetailSheet({super.key, required this.item});

  static void show(BuildContext context, TransactionItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final formattedAmount = '${item.isDebit ? '-' : '+'}${formatter.format(item.amount)}';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
          decoration: BoxDecoration(
            color: const Color(0xF00D0D1E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              // Status Icon Aura
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.iconBgColor,
                  border: Border.all(color: item.iconColor.withValues(alpha: 0.5)),
                  boxShadow: AppColors.neonGlow(
                    color: item.iconColor,
                    blurRadius: 18,
                    opacity: 0.35,
                  ),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 30),
              ),

              const SizedBox(height: 14),

              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.merchant,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),

              const SizedBox(height: 12),

              Text(
                formattedAmount,
                style: TextStyle(
                  color: item.isDebit ? Colors.white : AppColors.neonEmerald,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              // Completed status pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neonEmerald.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.neonEmerald, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Payment Completed',
                      style: TextStyle(
                        color: AppColors.neonEmerald,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Detailed metadata list
              GlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildRow('Category', item.categoryString),
                    const Divider(color: Colors.white10, height: 20),
                    _buildRow('Payment Source', item.paymentMethodName),
                    const Divider(color: Colors.white10, height: 20),
                    _buildRow('Reference Code', item.referenceNumber),
                    const Divider(color: Colors.white10, height: 20),
                    _buildRow('Timestamp', DateFormat('MMM d, y • hh:mm a').format(item.date)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: NeonButton(
                      text: 'Share Receipt',
                      icon: Icons.share_rounded,
                      isSecondary: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Receipt shared to clipboard link!'),
                            backgroundColor: Color(0xFF1E1B4B),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeonButton(
                      text: 'Repeat',
                      icon: Icons.refresh_rounded,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(
          val,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
