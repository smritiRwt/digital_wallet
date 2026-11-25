import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/wallet_state.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_checkmark.dart';
import '../widgets/neon_button.dart';

class AddMoneyModal extends StatefulWidget {
  const AddMoneyModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddMoneyModal(),
    );
  }

  @override
  State<AddMoneyModal> createState() => _AddMoneyModalState();
}

class _AddMoneyModalState extends State<AddMoneyModal> {
  final List<double> _presetAmounts = [50, 100, 250, 500, 1000];
  double _selectedAmount = 250;
  int _selectedBankIndex = 0;
  bool _isProcessing = false;
  bool _isSuccess = false;

  final List<Map<String, dynamic>> _banks = [
    {
      'name': 'JPMorgan Chase Premier',
      'account': 'Checking ••4812',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF00F0FF),
    },
    {
      'name': 'Silicon Valley Bank',
      'account': 'Savings ••9021',
      'icon': Icons.savings_rounded,
      'color': Color(0xFFA855F7),
    },
    {
      'name': 'Apple Cash Instant',
      'account': 'Instant Debit Direct',
      'icon': Icons.apple_rounded,
      'color': Colors.white,
    },
  ];

  void _handleAddMoney() {
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final bankName = _banks[_selectedBankIndex]['name'] as String;
      WalletState().addMoney(amount: _selectedAmount, source: bankName);
      HapticFeedback.heavyImpact();

      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });

      Future.delayed(const Duration(milliseconds: 1600), () {
        if (mounted) Navigator.of(context).pop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        14,
        22,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: const Color(0xF00D0D20),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: _isSuccess ? _buildSuccessContent() : _buildFormContent(),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        const AnimatedCheckmark(size: 80, color: AppColors.neonEmerald),
        const SizedBox(height: 16),
        const Text(
          'Funds Deposited!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '+\$${_selectedAmount.toStringAsFixed(2)} has been added to your wallet balance.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildFormContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add Money to Wallet',
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

        const SizedBox(height: 14),

        // Big Display Amount
        Center(
          child: Text(
            '\$${_selectedAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Preset amount buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _presetAmounts.map((amt) {
            final isSel = _selectedAmount == amt;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedAmount = amt);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSel
                      ? AppColors.electricPurple.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? AppColors.electricPurple : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  '+\$${amt.toInt()}',
                  style: TextStyle(
                    color: isSel ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 22),

        const Text(
          'Select Deposit Source',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),

        // Source Bank Selection
        Column(
          children: List.generate(_banks.length, (index) {
            final b = _banks[index];
            final isSel = index == _selectedBankIndex;
            final color = b['color'] as Color;

            return GestureDetector(
              onTap: () => setState(() => _selectedBankIndex = index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSel ? color.withValues(alpha: 0.12) : const Color(0x10FFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSel ? color : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(b['icon'] as IconData, color: color, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            b['account'] as String,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (isSel)
                      Icon(Icons.check_circle_rounded, color: color, size: 20),
                  ],
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 18),

        NeonButton(
          text: 'Deposit \$${_selectedAmount.toStringAsFixed(0)} Instantly',
          icon: Icons.add_circle_outline_rounded,
          isLoading: _isProcessing,
          onPressed: _handleAddMoney,
        ),
      ],
    );
  }
}
