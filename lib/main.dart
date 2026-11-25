import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/analytics_screen.dart';
import 'screens/cards_studio_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/send_payment_modal.dart';
import 'screens/transactions_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/animated_bottom_nav.dart';
import 'widgets/background/ambient_mesh_background.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF070712),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const NexusWalletApp());
}

class NexusWalletApp extends StatelessWidget {
  const NexusWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Digital Wallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainShellScreen(),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentTabIndex = 0;

  void _onTabSelect(int index) {
    setState(() => _currentTabIndex = index);
  }

  void _openQuickPay() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, anim1, anim2) => const SendPaymentModal(),
        transitionsBuilder: (context, anim, secondaryAnim, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeDashboardScreen(
        onSeeAllTransactions: () => _onTabSelect(3),
        onGoToCards: () => _onTabSelect(1),
      ),
      const CardsStudioScreen(),
      const AnalyticsScreen(),
      const TransactionsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: AmbientMeshBackground(
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _currentTabIndex,
            children: screens,
          ),
        ),
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _currentTabIndex,
        onTap: _onTabSelect,
        onQuickPay: _openQuickPay,
      ),
    );
  }
}
