import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_item.dart';
import '../providers/wallet_state.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_detail_sheet.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionCategory _selectedCategory = TransactionCategory.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = WalletState();

    return ListenableBuilder(
      listenable: state,
      builder: (context, child) {
        // Filter transactions based on category and search query
        final filtered = state.transactions.where((tx) {
          final matchesCategory = _selectedCategory == TransactionCategory.all ||
              tx.category == _selectedCategory;
          final matchesQuery = _searchQuery.isEmpty ||
              tx.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              tx.merchant.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesCategory && matchesQuery;
        }).toList();

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
                            'Transaction History',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Swipe left to repeat • Tap for full receipt',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.vividViolet.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filtered.length} Items',
                        style: const TextStyle(
                          color: AppColors.vividViolet,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Search Input Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
                      hintText: 'Search merchant, item, or ID...',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                      border: InputBorder.none,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildCategoryFilter('All', TransactionCategory.all),
                    _buildCategoryFilter('Tech', TransactionCategory.tech),
                    _buildCategoryFilter('Transfer', TransactionCategory.transfer),
                    _buildCategoryFilter('Shopping', TransactionCategory.shopping),
                    _buildCategoryFilter('Food & Drink', TransactionCategory.food),
                    _buildCategoryFilter('Entertainment', TransactionCategory.entertainment),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Transaction List Items
              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: Colors.white.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        const Text(
                          'No matching transactions found',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: List.generate(filtered.length, (index) {
                      final tx = filtered[index];
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
        );
      },
    );
  }

  Widget _buildCategoryFilter(String label, TransactionCategory cat) {
    final isSel = _selectedCategory == cat;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedCategory = cat);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSel
                ? AppColors.vividViolet.withValues(alpha: 0.28)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSel ? AppColors.vividViolet : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSel ? Colors.white : AppColors.textSecondary,
              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
