import 'package:flutter/material.dart';

enum CardBrand { visa, mastercard, amex }

class WalletCard {
  final String id;
  final String cardHolder;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final CardBrand brand;
  final String cardType; // "DEBIT" or "CREDIT"
  final List<Color> gradientColors;
  final Color accentColor;
  final double balance;
  final double spendLimit;
  final bool isFrozen;
  final String cardName;

  const WalletCard({
    required this.id,
    required this.cardHolder,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.brand,
    required this.cardType,
    required this.gradientColors,
    required this.accentColor,
    required this.balance,
    required this.spendLimit,
    this.isFrozen = false,
    required this.cardName,
  });

  String get maskedNumber {
    final clean = cardNumber.replaceAll(' ', '');
    if (clean.length < 16) return cardNumber;
    return '••••  ••••  ••••  ${clean.substring(12)}';
  }

  String get lastFourDigits {
    final clean = cardNumber.replaceAll(' ', '');
    return clean.length >= 4 ? clean.substring(clean.length - 4) : '••••';
  }

  WalletCard copyWith({
    String? id,
    String? cardHolder,
    String? cardNumber,
    String? expiryDate,
    String? cvv,
    CardBrand? brand,
    String? cardType,
    List<Color>? gradientColors,
    Color? accentColor,
    double? balance,
    double? spendLimit,
    bool? isFrozen,
    String? cardName,
  }) {
    return WalletCard(
      id: id ?? this.id,
      cardHolder: cardHolder ?? this.cardHolder,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      brand: brand ?? this.brand,
      cardType: cardType ?? this.cardType,
      gradientColors: gradientColors ?? this.gradientColors,
      accentColor: accentColor ?? this.accentColor,
      balance: balance ?? this.balance,
      spendLimit: spendLimit ?? this.spendLimit,
      isFrozen: isFrozen ?? this.isFrozen,
      cardName: cardName ?? this.cardName,
    );
  }
}
