import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_wallet_demo/main.dart';
import 'package:digital_wallet_demo/screens/cards_studio_screen.dart';
import 'package:digital_wallet_demo/screens/send_payment_modal.dart';
import 'package:digital_wallet_demo/widgets/animated_bottom_nav.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('App launches with Home Dashboard and 4 navigation tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NexusWalletApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('TOTAL WALLET BALANCE'), findsOneWidget);
    expect(find.text('Alexander Vane'), findsOneWidget);
    expect(find.text('My Virtual Cards'), findsOneWidget);
    expect(find.byType(AnimatedBottomNav), findsOneWidget);
  });

  testWidgets('Directly renders CardsStudioScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CardsStudioScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Card Studio'), findsOneWidget);
    expect(find.text('Monthly Spend Limit'), findsOneWidget);
    expect(find.text('Exclusive Card Perks'), findsOneWidget);
  });

  testWidgets('Directly renders SendPaymentModal and interacts with keypad', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SendPaymentModal()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Step 1 • Enter Amount'), findsOneWidget);
    expect(find.text('Continue to Payment Method'), findsOneWidget);

    // Tap quick amount chip +$100
    final chip = find.text('+\$100');
    expect(chip, findsOneWidget);
    await tester.tap(chip);
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Continue button is active and tap it
    final continueBtn = find.text('Continue to Payment Method');
    await tester.tap(continueBtn);
    await tester.pump(const Duration(milliseconds: 400));

    // Verify Step 2 reached
    expect(find.text('Step 2 • Payment Method'), findsOneWidget);
    expect(find.text('Select Source'), findsOneWidget);
  });
}
