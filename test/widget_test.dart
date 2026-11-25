import 'package:flutter_test/flutter_test.dart';
import 'package:digital_wallet_demo/main.dart';

void main() {
  testWidgets('Digital Wallet smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NexusWalletApp());
    expect(find.byType(NexusWalletApp), findsOneWidget);
  });
}
