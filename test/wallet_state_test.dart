import 'package:flutter_test/flutter_test.dart';
import 'package:digital_wallet_demo/providers/wallet_state.dart';
import 'package:digital_wallet_demo/models/transaction_item.dart';

void main() {
  group('WalletState Tests', () {
    late WalletState state;

    setUp(() {
      state = WalletState();
    });

    test('Initial balance and cards are properly initialized', () {
      expect(state.balance, greaterThan(0));
      expect(state.cards.length, equals(3));
      expect(state.activeCardIndex, equals(0));
      expect(state.isBalanceHidden, isFalse);
    });

    test('Toggle balance visibility flips flag', () {
      final initial = state.isBalanceHidden;
      state.toggleBalanceVisibility();
      expect(state.isBalanceHidden, equals(!initial));
      state.toggleBalanceVisibility();
      expect(state.isBalanceHidden, equals(initial));
    });

    test('Card selection updates activeCardIndex', () {
      state.setActiveCardIndex(1);
      expect(state.activeCardIndex, equals(1));
      expect(state.activeCard.cardName, contains('Cyber'));
    });

    test('Toggle freeze flips isFrozen state on target card', () {
      final cardId = state.activeCard.id;
      final initialFrozen = state.activeCard.isFrozen;
      state.toggleFreezeCard(cardId);
      expect(state.activeCard.isFrozen, equals(!initialFrozen));
      state.toggleFreezeCard(cardId);
      expect(state.activeCard.isFrozen, equals(initialFrozen));
    });

    test('Sending payment deducts balance and prepends transaction', () {
      final prevBalance = state.balance;
      final prevTxCount = state.transactions.length;

      state.sendPayment(
        amount: 250.00,
        recipientName: 'Elena Rostova',
        method: 'Digital Wallet Balance',
      );

      expect(state.balance, equals(prevBalance - 250.00));
      expect(state.transactions.length, equals(prevTxCount + 1));
      expect(state.transactions.first.amount, equals(250.00));
      expect(state.transactions.first.isDebit, isTrue);
      expect(state.transactions.first.category, equals(TransactionCategory.transfer));
    });

    test('Adding money increases balance and adds credit transaction', () {
      final prevBalance = state.balance;
      final prevTxCount = state.transactions.length;

      state.addMoney(
        amount: 500.00,
        source: 'JPMorgan Chase Premier',
      );

      expect(state.balance, equals(prevBalance + 500.00));
      expect(state.transactions.length, equals(prevTxCount + 1));
      expect(state.transactions.first.amount, equals(500.00));
      expect(state.transactions.first.isDebit, isFalse);
    });
  });
}
