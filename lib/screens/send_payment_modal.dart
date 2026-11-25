import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/payment_recipient.dart';
import '../providers/wallet_state.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_checkmark.dart';
import '../widgets/animated_counter.dart';
import '../widgets/background/ambient_mesh_background.dart';
import '../widgets/confetti_burst.dart';
import '../widgets/custom_numeric_keypad.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';

enum PaymentStep {
  enterAmount,
  selectMethod,
  confirmation,
  processing,
  success,
}

class SendPaymentModal extends StatefulWidget {
  final PaymentRecipient? initialRecipient;
  final PaymentStep initialStep;

  const SendPaymentModal({
    super.key,
    this.initialRecipient,
    this.initialStep = PaymentStep.enterAmount,
  });

  @override
  State<SendPaymentModal> createState() => _SendPaymentModalState();
}

class _SendPaymentModalState extends State<SendPaymentModal>
    with TickerProviderStateMixin {
  late PaymentStep _currentStep;
  late PaymentRecipient _selectedRecipient;

  // Step 1: Amount State
  String _amountString = '150';
  final List<double> _quickAmounts = [25, 50, 100, 250, 500];

  // Step 2: Payment Method State
  int _selectedMethodIndex = 0;
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'title': 'Digital Wallet Balance',
      'subtitle': 'Available: \$24,850.75',
      'icon': Icons.account_balance_wallet_rounded,
      'color': AppColors.electricPurple,
    },
    {
      'title': 'Instant Quantum UPI',
      'subtitle': 'Instant zero-fee settlement',
      'icon': Icons.flash_on_rounded,
      'color': AppColors.neonCyan,
    },
    {
      'title': 'Obsidian Debit Card (••9128)',
      'subtitle': 'Nexus Black Metal Tier',
      'icon': Icons.credit_card_rounded,
      'color': AppColors.vividViolet,
    },
    {
      'title': 'Cyber Credit Card (••3901)',
      'subtitle': 'Cashback 3.5% on tech',
      'icon': Icons.contactless_rounded,
      'color': AppColors.neonPink,
    },
  ];

  // Step 4: Processing Animation
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  int _processingStatusIndex = 0;
  final List<String> _processingStatuses = [
    'Connecting Quantum Enclave...',
    'Authenticating Biometric Token...',
    'Routing via Zero-Knowledge Wire...',
    'Finalizing Cryptographic Receipt...',
  ];

  // Step 5: Success Download State
  bool _isDownloadingReceipt = false;
  bool _hasDownloadedReceipt = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    final state = WalletState();
    _selectedRecipient = widget.initialRecipient ?? state.recipients.first;

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.88,
      upperBound: 1.08,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double get _numericAmount {
    return double.tryParse(_amountString) ?? 0.0;
  }

  void _onKeyPress(String value) {
    if (_amountString == '0') {
      setState(() => _amountString = value);
    } else {
      if (_amountString.contains('.')) {
        final parts = _amountString.split('.');
        if (parts.length > 1 && parts[1].length >= 2) return; // max 2 decimals
      }
      if (_amountString.length >= 7) return; // prevent overflow
      setState(() => _amountString += value);
    }
  }

  void _onDelete() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_amountString.length <= 1) {
        _amountString = '0';
      } else {
        _amountString = _amountString.substring(0, _amountString.length - 1);
      }
    });
  }

  void _onDecimal() {
    if (!_amountString.contains('.')) {
      setState(() => _amountString += '.');
    }
  }

  void _startProcessingFlow() {
    setState(() {
      _currentStep = PaymentStep.processing;
      _processingStatusIndex = 0;
    });

    _rotationController.repeat();

    // Progress status sequence
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _processingStatusIndex = 1);
    });
    Future.delayed(const Duration(milliseconds: 1350), () {
      if (mounted) setState(() => _processingStatusIndex = 2);
    });
    Future.delayed(const Duration(milliseconds: 2100), () {
      if (mounted) setState(() => _processingStatusIndex = 3);
    });

    // Complete payment and transition to Step 5: Success
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      _rotationController.stop();

      // Trigger actual balance deduction & transaction registration in WalletState!
      final state = WalletState();
      final methodTitle = _paymentMethods[_selectedMethodIndex]['title'] as String;
      state.sendPayment(
        amount: _numericAmount,
        recipientName: _selectedRecipient.name,
        method: methodTitle,
      );

      HapticFeedback.heavyImpact();
      setState(() {
        _currentStep = PaymentStep.success;
      });
    });
  }

  void _simulateDownloadReceipt() {
    setState(() => _isDownloadingReceipt = true);
    HapticFeedback.mediumImpact();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isDownloadingReceipt = false;
          _hasDownloadedReceipt = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.neonEmerald, size: 18),
                SizedBox(width: 8),
                Text('Receipt saved to Downloads (PDF)'),
              ],
            ),
            backgroundColor: const Color(0xFF1E1B4B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientMeshBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildStepContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (_currentStep == PaymentStep.success) {
      return const SizedBox.shrink();
    }

    String title;
    switch (_currentStep) {
      case PaymentStep.enterAmount:
        title = 'Step 1 • Enter Amount';
        break;
      case PaymentStep.selectMethod:
        title = 'Step 2 • Payment Method';
        break;
      case PaymentStep.confirmation:
        title = 'Step 3 • Review & Confirm';
        break;
      case PaymentStep.processing:
        title = 'Step 4 • Processing';
        break;
      case PaymentStep.success:
        title = 'Step 5 • Success';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () {
              if (_currentStep == PaymentStep.enterAmount) {
                Navigator.of(context).pop();
              } else if (_currentStep == PaymentStep.selectMethod) {
                setState(() => _currentStep = PaymentStep.enterAmount);
              } else if (_currentStep == PaymentStep.confirmation) {
                setState(() => _currentStep = PaymentStep.selectMethod);
              }
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case PaymentStep.enterAmount:
        return _buildStep1EnterAmount();
      case PaymentStep.selectMethod:
        return _buildStep2SelectMethod();
      case PaymentStep.confirmation:
        return _buildStep3Confirmation();
      case PaymentStep.processing:
        return _buildStep4Processing();
      case PaymentStep.success:
        return _buildStep5Success();
    }
  }

  // ================= STEP 1: ENTER AMOUNT =================
  Widget _buildStep1EnterAmount() {
    final state = WalletState();

    return Column(
      key: const ValueKey('step_1'),
      children: [
        // Recipient Selection Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: 18,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _selectedRecipient.avatarColor.withValues(alpha: 0.25),
                  child: Text(
                    _selectedRecipient.avatarInitials,
                    style: TextStyle(
                      color: _selectedRecipient.avatarColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedRecipient.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _selectedRecipient.username,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Switch recipient dropdown
                PopupMenuButton<PaymentRecipient>(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neonCyan),
                  color: const Color(0xFF1B1B38),
                  onSelected: (rec) => setState(() => _selectedRecipient = rec),
                  itemBuilder: (context) {
                    return state.recipients.map((r) {
                      return PopupMenuItem(
                        value: r,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: r.avatarColor.withValues(alpha: 0.25),
                              child: Text(
                                r.avatarInitials,
                                style: TextStyle(color: r.avatarColor, fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(r.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Animated Large Amount Display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 4.0),
              child: Text(
                '\$',
                style: TextStyle(
                  color: AppColors.neonCyan.withValues(alpha: 0.9),
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                color: Colors.white,
                fontSize: _amountString.length > 5 ? 42 : 56,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                letterSpacing: -1.0,
                shadows: [
                  BoxShadow(
                    color: AppColors.vividViolet.withValues(alpha: 0.4),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Text(_amountString),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Quick amount chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _quickAmounts.map((amt) {
              final isCurrent = _amountString == amt.toInt().toString();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _amountString = amt.toInt().toString());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.vividViolet.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.vividViolet
                            : Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      '+\$${amt.toInt()}',
                      style: TextStyle(
                        color: isCurrent ? Colors.white : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const Spacer(),

        // Numeric Keypad
        CustomNumericKeypad(
          onKeyPress: _onKeyPress,
          onDelete: _onDelete,
          onDecimal: _onDecimal,
        ),

        const SizedBox(height: 16),

        // Continue Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: NeonButton(
            text: 'Continue to Payment Method',
            icon: Icons.arrow_forward_rounded,
            onPressed: _numericAmount > 0
                ? () {
                    HapticFeedback.mediumImpact();
                    setState(() => _currentStep = PaymentStep.selectMethod);
                  }
                : null,
          ),
        ),
      ],
    );
  }

  // ================= STEP 2: SELECT METHOD =================
  Widget _buildStep2SelectMethod() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        key: const ValueKey('step_2'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Select Source',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose which card or balance to draw \$${_numericAmount.toStringAsFixed(2)} from.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView.separated(
              itemCount: _paymentMethods.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = _paymentMethods[index];
                final isSelected = index == _selectedMethodIndex;
                final color = item['color'] as Color;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedMethodIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.18)
                          : const Color(0x18FFFFFF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? color : Colors.white.withValues(alpha: 0.12),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? AppColors.neonGlow(color: color, blurRadius: 20, opacity: 0.4)
                          : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withValues(alpha: 0.2),
                            border: Border.all(color: color.withValues(alpha: 0.4)),
                          ),
                          child: Icon(item['icon'] as IconData, color: color, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item['subtitle'] as String,
                                style: TextStyle(
                                  color: isSelected ? Colors.white70 : AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 16),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          NeonButton(
            text: 'Review Transfer',
            icon: Icons.check_circle_outline_rounded,
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() => _currentStep = PaymentStep.confirmation);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ================= STEP 3: CONFIRMATION =================
  Widget _buildStep3Confirmation() {
    final method = _paymentMethods[_selectedMethodIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        key: const ValueKey('step_3'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Payment Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Please verify recipient and account details before sending.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Glass Card with full summary breakdown
          GlassCard(
            padding: const EdgeInsets.all(22),
            borderRadius: 22,
            child: Column(
              children: [
                // Transfer Amount Big
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Total Payment',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${NumberFormat('#,##0.00').format(_numericAmount)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 16),

                // Recipient Row
                _buildSummaryRow(
                  label: 'To Recipient',
                  value: _selectedRecipient.name,
                  subtitle: _selectedRecipient.username,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),

                // Method Row
                _buildSummaryRow(
                  label: 'Payment Method',
                  value: method['title'] as String,
                  icon: method['icon'] as IconData,
                  iconColor: method['color'] as Color,
                ),
                const SizedBox(height: 14),

                // Fee Row
                _buildSummaryRow(
                  label: 'Transfer Fee',
                  value: 'Free (\$0.00)',
                  valueColor: AppColors.neonEmerald,
                  icon: Icons.shield_outlined,
                ),
                const SizedBox(height: 14),

                // Security Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline_rounded, color: AppColors.neonCyan, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Protected by Quantum 256-bit biometrics & instant refund guarantee.',
                          style: TextStyle(
                            color: AppColors.neonCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Slide or Animated Pay Now Button
          NeonButton(
            text: 'Pay \$${_numericAmount.toStringAsFixed(2)} Now',
            icon: Icons.bolt_rounded,
            glowColor: AppColors.neonEmerald,
            gradient: const LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF00FF9D)],
            ),
            onPressed: () {
              HapticFeedback.heavyImpact();
              _startProcessingFlow();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    String? subtitle,
    required IconData icon,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.vividViolet).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.vividViolet, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
          ],
        ),
      ],
    );
  }

  // ================= STEP 4: PROCESSING =================
  Widget _buildStep4Processing() {
    return Center(
      key: const ValueKey('step_4'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Circular Loader with Rotating Gradient Ring
          ScaleTransition(
            scale: _pulseController,
            child: RotationTransition(
              turns: _rotationController,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const SweepGradient(
                    colors: [
                      Color(0x00A855F7),
                      Color(0xFF00F0FF),
                      Color(0xFFA855F7),
                      Color(0xFFFF2A85),
                    ],
                  ),
                  boxShadow: AppColors.neonGlow(
                    color: AppColors.neonCyan,
                    blurRadius: 32,
                    opacity: 0.45,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.sync_lock_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 38),

          Text(
            '\$${NumberFormat('#,##0.00').format(_numericAmount)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _processingStatuses[_processingStatusIndex],
              key: ValueKey(_processingStatusIndex),
              style: const TextStyle(
                color: AppColors.neonCyan,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            'Transferring in real-time, please hold...',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ================= STEP 5: SUCCESS =================
  Widget _buildStep5Success() {
    final method = _paymentMethods[_selectedMethodIndex];

    return Stack(
      key: const ValueKey('step_5'),
      children: [
        // Confetti burst explosion particles
        const Positioned.fill(
          child: ConfettiBurst(count: 65),
        ),

        // Success Contents
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Animated Drawing Checkmark
              const AnimatedCheckmark(
                size: 90,
                color: AppColors.neonEmerald,
              ),

              const SizedBox(height: 20),

              const Text(
                'Transfer Successful!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              // Animated Amount Counter
              AnimatedCounter(
                value: _numericAmount,
                style: const TextStyle(
                  color: AppColors.neonEmerald,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 24),

              // Digital Receipt Card
              GlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildReceiptRow('Sent To', _selectedRecipient.name),
                    const Divider(color: Colors.white10, height: 20),
                    _buildReceiptRow('Payment Method', method['title'] as String),
                    const Divider(color: Colors.white10, height: 20),
                    _buildReceiptRow(
                      'Transaction ID',
                      'NX-${math.Random().nextInt(899999) + 100000}',
                    ),
                    const Divider(color: Colors.white10, height: 20),
                    _buildReceiptRow('Timestamp', DateFormat('MMM d, y • HH:mm').format(DateTime.now())),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons: Download Receipt & Back to Home
              Row(
                children: [
                  Expanded(
                    child: NeonButton(
                      text: _hasDownloadedReceipt ? 'Saved ✓' : 'Receipt',
                      icon: _hasDownloadedReceipt
                          ? Icons.check_circle_rounded
                          : Icons.download_rounded,
                      isSecondary: true,
                      isLoading: _isDownloadingReceipt,
                      onPressed: _isDownloadingReceipt ? null : _simulateDownloadReceipt,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: NeonButton(
                      text: 'Back Home',
                      icon: Icons.home_rounded,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
