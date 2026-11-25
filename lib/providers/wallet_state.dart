import 'package:flutter/material.dart';
import '../models/wallet_card.dart';
import '../models/transaction_item.dart';
import '../models/payment_recipient.dart';

class WalletState extends ChangeNotifier {
  // Singleton pattern for simple global access across screens and modals
  static final WalletState _instance = WalletState._internal();
  factory WalletState() => _instance;
  WalletState._internal();

  double _balance = 24850.75;
  bool _isBalanceHidden = false;
  int _activeCardIndex = 0;

  double get balance => _balance;
  bool get isBalanceHidden => _isBalanceHidden;
  int get activeCardIndex => _activeCardIndex;

  WalletCard get activeCard => _cards[_activeCardIndex];

  final List<WalletCard> _cards = [
    const WalletCard(
      id: 'card_1',
      cardHolder: 'ALEXANDER VANE',
      cardNumber: '5342 8891 0244 9128',
      expiryDate: '09/29',
      cvv: '842',
      brand: CardBrand.visa,
      cardType: 'PLATINUM DEBIT',
      gradientColors: [Color(0xFF13132B), Color(0xFF2E1065), Color(0xFF4C1D95)],
      accentColor: Color(0xFFA855F7),
      balance: 18420.50,
      spendLimit: 30000.00,
      cardName: 'Obsidian Black Metal',
    ),
    const WalletCard(
      id: 'card_2',
      cardHolder: 'ALEXANDER VANE',
      cardNumber: '4198 6230 7715 3901',
      expiryDate: '11/30',
      cvv: '491',
      brand: CardBrand.mastercard,
      cardType: 'CYBER CREDIT',
      gradientColors: [Color(0xFF0F172A), Color(0xFF431407), Color(0xFFBE185D)],
      accentColor: Color(0xFFFF2A85),
      balance: 6430.25,
      spendLimit: 15000.00,
      cardName: 'Neon Cyber Violet',
    ),
    const WalletCard(
      id: 'card_3',
      cardHolder: 'ALEXANDER VANE',
      cardNumber: '3782 8224 0091 6452',
      expiryDate: '04/31',
      cvv: '710',
      brand: CardBrand.amex,
      cardType: 'TITANIUM TITAN',
      gradientColors: [Color(0xFF06283D), Color(0xFF1363DF), Color(0xFF00F0FF)],
      accentColor: Color(0xFF00F0FF),
      balance: 12980.00,
      spendLimit: 25000.00,
      cardName: 'Aurora Cyan Titan',
    ),
  ];

  List<WalletCard> get cards => List.unmodifiable(_cards);

  final List<PaymentRecipient> _recipients = [
    const PaymentRecipient(
      id: 'rec_1',
      name: 'Elena Rostova',
      username: '@elena.design',
      avatarInitials: 'ER',
      avatarColor: Color(0xFFA855F7),
      recentAmount: '\$250.00',
      isFavorite: true,
    ),
    const PaymentRecipient(
      id: 'rec_2',
      name: 'Marcus Chen',
      username: '@marcus.ai',
      avatarInitials: 'MC',
      avatarColor: Color(0xFF00F0FF),
      recentAmount: '\$1,200.00',
      isFavorite: true,
    ),
    const PaymentRecipient(
      id: 'rec_3',
      name: 'Sofia Alva',
      username: '@sofia_crypto',
      avatarInitials: 'SA',
      avatarColor: Color(0xFFFF2A85),
      recentAmount: '\$85.50',
      isFavorite: true,
    ),
    const PaymentRecipient(
      id: 'rec_4',
      name: 'Liam Wright',
      username: '@lwright',
      avatarInitials: 'LW',
      avatarColor: Color(0xFF10B981),
      recentAmount: '\$450.00',
      isFavorite: false,
    ),
    const PaymentRecipient(
      id: 'rec_5',
      name: 'Nova Labs',
      username: '@novalabs',
      avatarInitials: 'NL',
      avatarColor: Color(0xFFFFB800),
      recentAmount: '\$3,400.00',
      isFavorite: false,
    ),
  ];

  List<PaymentRecipient> get recipients => List.unmodifiable(_recipients);

  final List<TransactionItem> _transactions = [
    TransactionItem(
      id: 'tx_1',
      title: 'Apple Store Online',
      merchant: 'Cupertino, CA',
      category: TransactionCategory.tech,
      amount: 1499.00,
      isDebit: true,
      date: DateTime.now().subtract(const Duration(minutes: 42)),
      icon: Icons.laptop_mac_rounded,
      iconColor: const Color(0xFF00F0FF),
      iconBgColor: const Color(0x2200F0FF),
      referenceNumber: 'TX-APL-882941',
      paymentMethodName: 'Obsidian Debit Card',
    ),
    TransactionItem(
      id: 'tx_2',
      title: 'Quantum Labs Payout',
      merchant: 'Freelance & Royalties',
      category: TransactionCategory.transfer,
      amount: 4850.00,
      isDebit: false,
      date: DateTime.now().subtract(const Duration(hours: 4)),
      icon: Icons.arrow_downward_rounded,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0x2210B981),
      referenceNumber: 'TX-INC-109284',
      paymentMethodName: 'Instant UPI Wire',
    ),
    TransactionItem(
      id: 'tx_3',
      title: 'Tesla Supercharging',
      merchant: 'Station #402 Palo Alto',
      category: TransactionCategory.tech,
      amount: 38.60,
      isDebit: true,
      date: DateTime.now().subtract(const Duration(hours: 9)),
      icon: Icons.electric_car_rounded,
      iconColor: const Color(0xFFFF2A85),
      iconBgColor: const Color(0x22FF2A85),
      referenceNumber: 'TX-TSL-390192',
      paymentMethodName: 'Cyber Credit Card',
    ),
    TransactionItem(
      id: 'tx_4',
      title: 'Spotify Duo Subscription',
      merchant: 'Recurring Monthly',
      category: TransactionCategory.entertainment,
      amount: 14.99,
      isDebit: true,
      date: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.graphic_eq_rounded,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0x2210B981),
      referenceNumber: 'TX-SPT-991204',
      paymentMethodName: 'Obsidian Debit Card',
    ),
    TransactionItem(
      id: 'tx_5',
      title: 'Nike Air Innovation',
      merchant: 'Nike Flagship',
      category: TransactionCategory.shopping,
      amount: 220.00,
      isDebit: true,
      date: DateTime.now().subtract(const Duration(days: 2)),
      icon: Icons.shopping_bag_rounded,
      iconColor: const Color(0xFFA855F7),
      iconBgColor: const Color(0x22A855F7),
      referenceNumber: 'TX-NKE-554109',
      paymentMethodName: 'Aurora Cyan Titan',
    ),
    TransactionItem(
      id: 'tx_6',
      title: 'Blue Bottle Coffee',
      merchant: 'Artisan Espresso',
      category: TransactionCategory.food,
      amount: 9.75,
      isDebit: true,
      date: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      icon: Icons.coffee_rounded,
      iconColor: const Color(0xFFFFB800),
      iconBgColor: const Color(0x22FFB800),
      referenceNumber: 'TX-BBC-231140',
      paymentMethodName: 'Digital Wallet Balance',
    ),
    TransactionItem(
      id: 'tx_7',
      title: 'Transfer from Elena',
      merchant: 'Split Bill Payment',
      category: TransactionCategory.transfer,
      amount: 125.00,
      isDebit: false,
      date: DateTime.now().subtract(const Duration(days: 3)),
      icon: Icons.swap_horiz_rounded,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0x2210B981),
      referenceNumber: 'TX-ELN-773419',
      paymentMethodName: 'Direct P2P Transfer',
    ),
  ];

  List<TransactionItem> get transactions => List.unmodifiable(_transactions);

  void toggleBalanceVisibility() {
    _isBalanceHidden = !_isBalanceHidden;
    notifyListeners();
  }

  void setActiveCardIndex(int index) {
    if (index >= 0 && index < _cards.length) {
      _activeCardIndex = index;
      notifyListeners();
    }
  }

  void toggleFreezeCard(String cardId) {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      final current = _cards[index];
      _cards[index] = current.copyWith(isFrozen: !current.isFrozen);
      notifyListeners();
    }
  }

  void sendPayment({
    required double amount,
    required String recipientName,
    required String method,
  }) {
    _balance = (_balance - amount).clamp(0.0, double.infinity);

    final newTx = TransactionItem(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Payment to $recipientName',
      merchant: 'Instant Transfer',
      category: TransactionCategory.transfer,
      amount: amount,
      isDebit: true,
      date: DateTime.now(),
      icon: Icons.send_rounded,
      iconColor: const Color(0xFFA855F7),
      iconBgColor: const Color(0x22A855F7),
      referenceNumber: 'TX-QNT-${DateTime.now().millisecondsSinceEpoch % 1000000}',
      paymentMethodName: method,
    );

    _transactions.insert(0, newTx);
    notifyListeners();
  }

  void addMoney({
    required double amount,
    required String source,
  }) {
    _balance += amount;

    final newTx = TransactionItem(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Top Up from $source',
      merchant: 'Deposit to Digital Wallet',
      category: TransactionCategory.transfer,
      amount: amount,
      isDebit: false,
      date: DateTime.now(),
      icon: Icons.add_circle_outline_rounded,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0x2210B981),
      referenceNumber: 'TX-DEP-${DateTime.now().millisecondsSinceEpoch % 1000000}',
      paymentMethodName: source,
    );

    _transactions.insert(0, newTx);
    notifyListeners();
  }
}
