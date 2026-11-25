import 'package:flutter/material.dart';
import '../models/wallet_card.dart';
import 'interactive_3d_card.dart';

class CardsCarouselStack extends StatefulWidget {
  final List<WalletCard> cards;
  final int activeIndex;
  final ValueChanged<int> onCardChanged;
  final VoidCallback? onFreezeToggle;

  const CardsCarouselStack({
    super.key,
    required this.cards,
    required this.activeIndex,
    required this.onCardChanged,
    this.onFreezeToggle,
  });

  @override
  State<CardsCarouselStack> createState() => _CardsCarouselStackState();
}

class _CardsCarouselStackState extends State<CardsCarouselStack> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.88,
      initialPage: widget.activeIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.cards.length,
        onPageChanged: widget.onCardChanged,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final card = widget.cards[index];
          final isSelected = index == widget.activeIndex;

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double scale = 1.0;
              double opacity = 1.0;

              if (_pageController.position.haveDimensions) {
                final page = _pageController.page ?? _pageController.initialPage.toDouble();
                final diff = (index - page).abs();
                scale = (1.0 - (diff * 0.12)).clamp(0.85, 1.0);
                opacity = (1.0 - (diff * 0.35)).clamp(0.5, 1.0);
              } else {
                scale = isSelected ? 1.0 : 0.90;
                opacity = isSelected ? 1.0 : 0.65;
              }

              return Center(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Interactive3DCard(
                      card: card,
                      isSelected: isSelected,
                      onFreezeToggle: widget.onFreezeToggle,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
