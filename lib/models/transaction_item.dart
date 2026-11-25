import 'package:flutter/material.dart';

enum TransactionStatus { completed, processing, failed }

enum TransactionCategory {
  all,
  shopping,
  transfer,
  food,
  entertainment,
  tech,
  bills,
}

class TransactionItem {
  final String id;
  final String title;
  final String merchant;
  final TransactionCategory category;
  final double amount;
  final bool isDebit; // true for money out, false for money in
  final DateTime date;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final TransactionStatus status;
  final String referenceNumber;
  final String paymentMethodName;

  const TransactionItem({
    required this.id,
    required this.title,
    required this.merchant,
    required this.category,
    required this.amount,
    required this.isDebit,
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.status = TransactionStatus.completed,
    required this.referenceNumber,
    required this.paymentMethodName,
  });

  String get categoryString {
    switch (category) {
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.transfer:
        return 'Transfer';
      case TransactionCategory.food:
        return 'Food & Drinks';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.tech:
        return 'Technology';
      case TransactionCategory.bills:
        return 'Bills & Utilities';
      case TransactionCategory.all:
        return 'General';
    }
  }
}
