import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../providers/wallet_state.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/interactive_3d_card.dart';
import '../widgets/neon_button.dart';

class CardsStudioScreen extends StatefulWidget {
  const CardsStudioScreen({super.key});

  @override
  State<CardsStudioScreen> createState() => _CardsStudioScreenState();
}

class _CardsStudioScreenState extends State<CardsStudioScreen> {
  double _spendLimit = 15000.0;
  bool _onlinePayments = true;
  bool _internationalUsage = true;
  bool _showPin = false;

  @override
  Widget build(BuildContext context) {
    final state = WalletState();

    return ListenableBuilder(
      listenable: state,
      builder: (context, child) {
        final currentCard = state.activeCard;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Card Studio',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Drag to tilt 3D • Double-tap to flip',
                            style: TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: currentCard.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: currentCard.accentColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '${state.activeCardIndex + 1} of ${state.cards.length}',
                        style: TextStyle(
                          color: currentCard.accentColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Card Selector Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(state.cards.length, (index) {
                    final card = state.cards[index];
                    final isSel = index == state.activeCardIndex;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          state.setActiveCardIndex(index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? card.accentColor.withValues(alpha: 0.22)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSel ? card.accentColor : Colors.white.withValues(alpha: 0.1),
                              width: isSel ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: card.accentColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                card.cardName,
                                style: TextStyle(
                                  color: isSel ? Colors.white : AppColors.textSecondary,
                                  fontSize: 12.5,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // Centered Main 3D Interactive Virtual Card
              Center(
                child: Interactive3DCard(
                  key: ValueKey(currentCard.id),
                  card: currentCard,
                  isSelected: true,
                  width: 345,
                  height: 215,
                  onFreezeToggle: () => state.toggleFreezeCard(currentCard.id),
                ),
              ),

              const SizedBox(height: 24),

              // Primary Card Action Buttons (Freeze, PIN, Details)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: NeonButton(
                        text: currentCard.isFrozen ? 'Unfreeze' : 'Freeze Card',
                        icon: currentCard.isFrozen ? Icons.wb_sunny_rounded : Icons.ac_unit_rounded,
                        isSecondary: !currentCard.isFrozen,
                        glowColor: const Color(0xFF38BDF8),
                        gradient: currentCard.isFrozen
                            ? const LinearGradient(
                                colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                              )
                            : null,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          state.toggleFreezeCard(currentCard.id);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeonButton(
                        text: _showPin ? 'PIN: 9042' : 'View PIN',
                        icon: _showPin ? Icons.visibility_off_rounded : Icons.lock_outline_rounded,
                        isSecondary: true,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _showPin = !_showPin);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // Spending Limit & Controls Glass Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Monthly Spend Limit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${NumberFormat('#,##0').format(_spendLimit)}',
                            style: const TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: currentCard.accentColor,
                          inactiveTrackColor: Colors.white12,
                          thumbColor: Colors.white,
                          overlayColor: currentCard.accentColor.withValues(alpha: 0.2),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: _spendLimit,
                          min: 1000,
                          max: 30000,
                          divisions: 29,
                          onChanged: (val) {
                            setState(() => _spendLimit = val);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 8),

                      // Toggle 1: Online Payments
                      _buildSwitchRow(
                        title: 'Online Commerce',
                        subtitle: 'E-commerce and app subscriptions',
                        value: _onlinePayments,
                        accentColor: currentCard.accentColor,
                        onChanged: (v) => setState(() => _onlinePayments = v),
                      ),

                      const SizedBox(height: 14),

                      // Toggle 2: International Transactions
                      _buildSwitchRow(
                        title: 'International Roaming',
                        subtitle: 'Zero FX surcharge anywhere',
                        value: _internationalUsage,
                        accentColor: currentCard.accentColor,
                        onChanged: (v) => setState(() => _internationalUsage = v),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Exclusive Tier Perks
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: const Text(
                  'Exclusive Card Perks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPerkTile(
                        icon: Icons.currency_bitcoin_rounded,
                        title: '3.5% Crypto',
                        desc: 'Cashback on tech',
                        color: AppColors.neonAmber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPerkTile(
                        icon: Icons.flight_takeoff_rounded,
                        title: 'VIP Lounge',
                        desc: 'Global Priority Pass',
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required Color accentColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: value,
          onChanged: (v) {
            HapticFeedback.lightImpact();
            onChanged(v);
          },
          activeThumbColor: accentColor,
          activeTrackColor: accentColor.withValues(alpha: 0.35),
          inactiveThumbColor: Colors.white54,
          inactiveTrackColor: Colors.white10,
        ),
      ],
    );
  }

  Widget _buildPerkTile({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
