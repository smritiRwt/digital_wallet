import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wallet_card.dart';
import '../theme/app_colors.dart';
import 'emv_chip.dart';

class Interactive3DCard extends StatefulWidget {
  final WalletCard card;
  final bool isSelected;
  final VoidCallback? onCardTap;
  final VoidCallback? onFreezeToggle;
  final double width;
  final double height;

  const Interactive3DCard({
    super.key,
    required this.card,
    this.isSelected = true,
    this.onCardTap,
    this.onFreezeToggle,
    this.width = 330.0,
    this.height = 205.0,
  });

  @override
  State<Interactive3DCard> createState() => _Interactive3DCardState();
}

class _Interactive3DCardState extends State<Interactive3DCard>
    with TickerProviderStateMixin {
  // 3D tilt tracking
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  // Controllers
  late AnimationController _springBackController;
  late Animation<double> _tiltXAnim;
  late Animation<double> _tiltYAnim;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Reveal CVV toggle
  bool _showCvv = false;

  // Copied indicator
  bool _justCopied = false;

  @override
  void initState() {
    super.initState();

    _springBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.easeInOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _springBackController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.card.isFrozen) return;

    // Calculate delta normalized tilt
    setState(() {
      _tiltY += details.delta.dx * 0.003;
      _tiltX -= details.delta.dy * 0.003;

      // Clamping limits for realistic perspective
      _tiltX = _tiltX.clamp(-0.28, 0.28);
      _tiltY = _tiltY.clamp(-0.35, 0.35);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // Spring back to resting state
    _tiltXAnim = Tween<double>(begin: _tiltX, end: 0.0).animate(
      CurvedAnimation(
        parent: _springBackController,
        curve: Curves.easeOutBack,
      ),
    );
    _tiltYAnim = Tween<double>(begin: _tiltY, end: 0.0).animate(
      CurvedAnimation(
        parent: _springBackController,
        curve: Curves.easeOutBack,
      ),
    );

    _springBackController.forward(from: 0.0).then((_) {
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  void _toggleFlip() {
    HapticFeedback.mediumImpact();
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  void _copyCardNumber() {
    Clipboard.setData(ClipboardData(text: widget.card.cardNumber));
    HapticFeedback.selectionClick();
    setState(() => _justCopied = true);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.neonEmerald, size: 18),
            const SizedBox(width: 8),
            Text(
              'Card number copied to clipboard',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1B4B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: widget.card.accentColor.withValues(alpha: 0.4)),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _justCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_springBackController, _flipController]),
      builder: (context, child) {
        final currentTiltX = _springBackController.isAnimating ? _tiltXAnim.value : _tiltX;
        final currentTiltY = _springBackController.isAnimating ? _tiltYAnim.value : _tiltY;
        final flipVal = _flipAnimation.value;

        // Is back side currently showing?
        final isBack = flipVal > (math.pi / 2);

        // Perspective 3D matrix
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateX(currentTiltX)
          ..rotateY(currentTiltY + flipVal);

        return GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onDoubleTap: _toggleFlip,
          onTap: widget.onCardTap,
          child: Transform(
            alignment: Alignment.center,
            transform: matrix,
            child: Stack(
              children: [
                // Active Glow & Container
                Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 28,
                        offset: Offset(currentTiltY * 25, 14 + currentTiltX * 15),
                      ),
                      if (widget.isSelected && !widget.card.isFrozen)
                        BoxShadow(
                          color: widget.card.accentColor.withValues(alpha: 0.38),
                          blurRadius: 26,
                          spreadRadius: 1,
                        ),
                      if (widget.card.isFrozen)
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                          blurRadius: 24,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.card.isFrozen
                              ? const [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF164E63)]
                              : widget.card.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: widget.card.isFrozen
                              ? const Color(0xFF38BDF8).withValues(alpha: 0.6)
                              : (widget.isSelected
                                  ? widget.card.accentColor.withValues(alpha: 0.65)
                                  : Colors.white.withValues(alpha: 0.15)),
                          width: widget.isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Dynamic Holographic Sheen Layer
                          _buildHolographicSheen(currentTiltX, currentTiltY),

                          // Front or Back content
                          if (!isBack)
                            _buildFrontContent()
                          else
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(math.pi),
                              child: _buildBackContent(),
                            ),

                          // Freeze Overlay Animation
                          if (widget.card.isFrozen) _buildFrozenOverlay(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Floating flip hint button in top corner
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: _toggleFlip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flip_rounded,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isBack ? 'Front' : 'Flip',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHolographicSheen(double tiltX, double tiltY) {
    // Dynamic light reflection shifting with finger movement
    final alignX = (tiltY * 3.5).clamp(-1.0, 1.0);
    final alignY = (tiltX * 3.5).clamp(-1.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(alignX - 0.7, alignY - 0.7),
          end: Alignment(alignX + 0.7, alignY + 0.7),
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.04),
            widget.card.accentColor.withValues(alpha: 0.14),
            Colors.white.withValues(alpha: 0.22),
            AppColors.neonCyan.withValues(alpha: 0.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.45, 0.52, 0.65, 1.0],
        ),
      ),
    );
  }

  Widget _buildFrontContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top row: Brand & NFC icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: widget.card.accentColor.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.bolt_rounded, color: Colors.white, size: 15),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'NEXUS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                      shadows: [
                        Shadow(
                          color: widget.card.accentColor.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Card type badge & Contactless wave icon
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.contactless_rounded,
                    color: Colors.white.withValues(alpha: 0.75),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.card.cardType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // EMV Chip & Hologram
          Row(
            children: [
              const EmvChip(width: 42, height: 32),
              const SizedBox(width: 14),
              // Hologram patch
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const SweepGradient(
                    colors: [
                      Color(0xFFFFDF7A),
                      Color(0xFF00F0FF),
                      Color(0xFFFF2A85),
                      Color(0xFF10B981),
                      Color(0xFFFFDF7A),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.fingerprint_rounded,
                    size: 16,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),

          // Card Number with Masking & Copy feedback
          GestureDetector(
            onTap: _copyCardNumber,
            behavior: HitTestBehavior.opaque,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.card.maskedNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _justCopied ? Icons.check_rounded : Icons.copy_rounded,
                    color: _justCopied ? AppColors.neonEmerald : Colors.white.withValues(alpha: 0.4),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Row: Cardholder & Expiry & Network Brand
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CARDHOLDER',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 7.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.card.cardHolder,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 7.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.card.expiryDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Network Logo
              _buildNetworkLogo(widget.card.brand),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        // Magnetic Strip
        Container(
          width: double.infinity,
          height: 38,
          color: const Color(0xFF0A0A10),
          child: Row(
            children: List.generate(
              16,
              (index) => Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: index.isEven ? 0.04 : 0.0),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Signature Strip & CVV
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Signature white box
              Expanded(
                flex: 4,
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'AUTHORIZED SIGNATURE',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.4),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // CVV Box with toggle
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _showCvv = !_showCvv);
                },
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: widget.card.accentColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _showCvv ? widget.card.cvv : '•••',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showCvv ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 13,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Backside security text & hotline
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Issued by Nexus Digital Bank under license. For customer care: +1-800-NEXUS-PAY. 24/7 Quantum Fraud Shield Active.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 7.5,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Hologram security sticker
              Container(
                width: 32,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFFCBD5E1)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'SECURE',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 6,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrozenOverlay() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            color: const Color(0x750284C7),
            child: Stack(
              children: [
                // Frost crystals custom painter
                CustomPaint(
                  size: Size(widget.width, widget.height),
                  painter: _FrostPainter(),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ac_unit_rounded, color: Color(0xFF38BDF8), size: 18),
                        SizedBox(width: 6),
                        Text(
                          'CARD FROZEN',
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkLogo(CardBrand brand) {
    switch (brand) {
      case CardBrand.visa:
        return const Text(
          'VISA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
          ),
        );
      case CardBrand.mastercard:
        return SizedBox(
          width: 36,
          height: 22,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEB001B),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF79E1B).withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        );
      case CardBrand.amex:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF0077A6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'AMEX',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        );
    }
  }
}

class _FrostPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Corner ice crystal lines
    canvas.drawLine(const Offset(0, 0), const Offset(45, 45), paint);
    canvas.drawLine(const Offset(15, 0), const Offset(45, 30), paint);
    canvas.drawLine(const Offset(0, 15), const Offset(30, 45), paint);

    canvas.drawLine(Offset(size.width, 0), Offset(size.width - 45, 45), paint);
    canvas.drawLine(Offset(size.width - 15, 0), Offset(size.width - 45, 30), paint);
    canvas.drawLine(Offset(size.width, 15), Offset(size.width - 30, 45), paint);

    canvas.drawLine(Offset(0, size.height), Offset(45, size.height - 45), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - 45, size.height - 45), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
