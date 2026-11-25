import 'package:flutter/material.dart';

class PaymentRecipient {
  final String id;
  final String name;
  final String username;
  final String avatarInitials;
  final Color avatarColor;
  final String recentAmount;
  final bool isFavorite;

  const PaymentRecipient({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarInitials,
    required this.avatarColor,
    required this.recentAmount,
    this.isFavorite = false,
  });
}
