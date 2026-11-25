import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_wallet_demo/main.dart';
import 'package:digital_wallet_demo/screens/cards_studio_screen.dart';
import 'package:digital_wallet_demo/screens/analytics_screen.dart';
import 'package:digital_wallet_demo/screens/send_payment_modal.dart';
import 'package:digital_wallet_demo/screens/transactions_screen.dart';
import 'package:digital_wallet_demo/theme/app_theme.dart';
import 'package:digital_wallet_demo/widgets/background/ambient_mesh_background.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    AppTheme.useGoogleFonts = false;
  });

  Future<void> captureWidget({
    required WidgetTester tester,
    required Widget widget,
    required String filename,
  }) async {
    final boundaryKey = GlobalKey();

    tester.view.physicalSize = const Size(860, 1864);
    tester.view.devicePixelRatio = 2.0;

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: RepaintBoundary(
          key: boundaryKey,
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(430, 932),
              padding: EdgeInsets.only(top: 48, bottom: 34),
              devicePixelRatio: 2.0,
            ),
            child: widget,
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 600));

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          File('screenshots/$filename').writeAsBytesSync(pngBytes);
        }
      }
    });

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  testWidgets('Capture Dashboard Screenshot', (WidgetTester tester) async {
    await captureWidget(
      tester: tester,
      widget: const MainShellScreen(),
      filename: '01_dashboard.png',
    );
  });

  testWidgets('Capture Card Studio Screenshot', (WidgetTester tester) async {
    await captureWidget(
      tester: tester,
      widget: const Scaffold(
        backgroundColor: Colors.transparent,
        body: AmbientMeshBackground(
          child: SafeArea(child: CardsStudioScreen()),
        ),
      ),
      filename: '02_card_studio.png',
    );
  });

  testWidgets('Capture Payment Flow Step 1 Screenshot', (WidgetTester tester) async {
    await captureWidget(
      tester: tester,
      widget: const SendPaymentModal(),
      filename: '03_payment_keypad.png',
    );
  });

  testWidgets('Capture Payment Success Screenshot', (WidgetTester tester) async {
    await captureWidget(
      tester: tester,
      widget: const SendPaymentModal(initialStep: PaymentStep.success),
      filename: '04_payment_success.png',
    );
  });

  testWidgets('Capture Analytics Screenshot', (WidgetTester tester) async {
    await captureWidget(
      tester: tester,
      widget: const Scaffold(
        backgroundColor: Colors.transparent,
        body: AmbientMeshBackground(
          child: SafeArea(child: AnalyticsScreen()),
        ),
      ),
      filename: '05_analytics.png',
    );
  });

  testWidgets('Capture Transactions Activity Screenshot', (WidgetTester tester) async {
    await captureWidget(
      tester: tester,
      widget: const Scaffold(
        backgroundColor: Colors.transparent,
        body: AmbientMeshBackground(
          child: SafeArea(child: TransactionsScreen()),
        ),
      ),
      filename: '06_transactions.png',
    );
  });
}
