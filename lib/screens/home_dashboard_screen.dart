import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/payment_recipient.dart';
import '../providers/wallet_state.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_counter.dart';
import '../widgets/cards_carousel_stack.dart';
import '../widgets/glass_card.dart';
import '../widgets/spending_progress_ring.dart';
import '../widgets/transaction_tile.dart';
import 'add_money_modal.dart';
import 'receive_money_modal.dart';
import 'send_payment_modal.dart';
import 'transaction_detail_sheet.dart';

class HomeDashboardScreen extends StatefulWidget {
  final VoidCallback onSeeAllTransactions;
  final VoidCallback onGoToCards;

  const HomeDashboardScreen({
    super.key,
    required this.onSeeAllTransactions,
    required this.onGoToCards,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() {});
  }

  void _openSendModal([PaymentRecipient? recipient]) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, anim1, anim2) => SendPaymentModal(initialRecipient: recipient),
        transitionsBuilder: (context, anim, secondaryAnim, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = WalletState();

    return ListenableBuilder(
      listenable: state,
      builder: (context, child) {
        final recentTransactions = state.transactions.take(4).toList();

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.neonCyan,
          backgroundColor: const Color(0xFF1B1B38),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Top User Header Bar
                _buildUserHeader(),

                const SizedBox(height: 20),

                // Balance Overview Card
                _buildBalanceCard(state),

                const SizedBox(height: 24),

                // Section Title & Cards Carousel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'My Virtual Cards',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: widget.onGoToCards,
                        child: const Row(
                          children: [
                            Text(
                              'Card Studio',
                              style: TextStyle(
                                color: AppColors.neonCyan,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, color: AppColors.neonCyan, size: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 3D Interactive Cards Carousel Stack
                CardsCarouselStack(
                  cards: state.cards,
                  activeIndex: state.activeCardIndex,
                  onCardChanged: state.setActiveCardIndex,
                  onFreezeToggle: () => state.toggleFreezeCard(state.activeCard.id),
                ),

                const SizedBox(height: 24),

                // Quick Action Buttons
                _buildQuickActionButtons(),

                const SizedBox(height: 24),

                // Quick Send Avatars
                _buildQuickSendAvatars(state),

                const SizedBox(height: 26),

                // Spending Insights Overview Ring
                _buildSpendingOverview(),

                const SizedBox(height: 26),

                // Recent Transactions Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Recent Transactions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: widget.onSeeAllTransactions,
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            color: AppColors.vividViolet,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Staggered Transaction List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: List.generate(recentTransactions.length, (index) {
                      final tx = recentTransactions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TransactionTile(
                          item: tx,
                          onTap: () => TransactionDetailSheet.show(context, tx),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: AppColors.neonGlow(color: AppColors.vividViolet, blurRadius: 16),
                  ),
                  child: const Center(
                    child: Text(
                      'AV',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                      ),
                      Text(
                        'Alexander Vane',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Notification Bell with Glowing Badge
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0x18FFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonPink,
                    boxShadow: AppColors.neonGlow(color: AppColors.neonPink, blurRadius: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(WalletState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonEmerald,
                        boxShadow: AppColors.neonGlow(color: AppColors.neonEmerald, blurRadius: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'TOTAL WALLET BALANCE',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    state.toggleBalanceVisibility();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      state.isBalanceHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.neonCyan,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Animated Counter
            AnimatedCounter(
              value: state.balance,
              isHidden: state.isBalanceHidden,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 12),

            // Growth indicator pill
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neonEmerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.neonEmerald.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_outward_rounded, color: AppColors.neonEmerald, size: 14),
                      SizedBox(width: 4),
                      Text(
                        '+\$1,420.50 (+6.4%)',
                        style: TextStyle(
                          color: AppColors.neonEmerald,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'this week',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            label: 'Send',
            icon: Icons.arrow_upward_rounded,
            color: AppColors.electricPurple,
            onTap: () => _openSendModal(),
          ),
          _buildActionButton(
            label: 'Receive',
            icon: Icons.arrow_downward_rounded,
            color: AppColors.neonCyan,
            onTap: () => ReceiveMoneyModal.show(context),
          ),
          _buildActionButton(
            label: 'Add Money',
            icon: Icons.add_rounded,
            color: AppColors.neonEmerald,
            onTap: () => AddMoneyModal.show(context),
          ),
          _buildActionButton(
            label: 'Cards',
            icon: Icons.credit_card_rounded,
            color: AppColors.neonPink,
            onTap: widget.onGoToCards,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.35)),
              boxShadow: AppColors.neonGlow(color: color, blurRadius: 16, opacity: 0.25),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSendAvatars(WalletState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quick Transfer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () => _openSendModal(),
                child: const Text(
                  'Search All',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // New recipient add button
              GestureDetector(
                onTap: () => _openSendModal(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: Column(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), style: BorderStyle.solid),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'New',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),

              // Favorites avatars
              ...state.recipients.map((rec) {
                return GestureDetector(
                  onTap: () => _openSendModal(rec),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14.0),
                    child: Column(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: rec.avatarColor.withValues(alpha: 0.2),
                            border: Border.all(color: rec.avatarColor.withValues(alpha: 0.5)),
                            boxShadow: AppColors.neonGlow(color: rec.avatarColor, blurRadius: 10, opacity: 0.25),
                          ),
                          child: Center(
                            child: Text(
                              rec.avatarInitials,
                              style: TextStyle(
                                color: rec.avatarColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          rec.name.split(' ').first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Spending Breakdown',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'This Month',
                    style: TextStyle(color: AppColors.neonCyan, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SpendingProgressRing(totalSpent: 3840.50),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSpendingLegend(
                        label: 'Shopping',
                        percent: '38%',
                        amount: '\$1,459',
                        color: const Color(0xFFA855F7),
                      ),
                      const SizedBox(height: 10),
                      _buildSpendingLegend(
                        label: 'Tech & Gadgets',
                        percent: '32%',
                        amount: '\$1,228',
                        color: const Color(0xFF00F0FF),
                      ),
                      const SizedBox(height: 10),
                      _buildSpendingLegend(
                        label: 'Dining & Food',
                        percent: '18%',
                        amount: '\$691',
                        color: const Color(0xFFFFB800),
                      ),
                      const SizedBox(height: 10),
                      _buildSpendingLegend(
                        label: 'Subscriptions',
                        percent: '12%',
                        amount: '\$462',
                        color: const Color(0xFFFF2A85),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingLegend({
    required String label,
    required String percent,
    required String amount,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
        Text(
          amount,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
