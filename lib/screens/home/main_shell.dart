import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/drinks_provider.dart';
import '../../widgets/achievement_unlock_overlay.dart';
import '../contact/contact_screen.dart';
import '../home/home_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../support/support_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Kontakt záložka je dočasne schovaná (kód zostáva pripravený, len sa
  // nezobrazuje) — kým sa neoverí funkčnosť appky a nerozhodne sa, či ostane.
  // Prepnutím na true sa vráti ako záložka presne v stave, v akom bola.
  static const bool _kShowContactTab = false;

  int _index = 0;

  static const _pages = [
    HomeScreen(),
    SupportScreen(),
    LeaderboardScreen(),
    if (_kShowContactTab) ContactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    // Novoodomknuté odznaky (naraz sa zobrazí len prvý, po jeho zatvorení sa
    // celá dávka odznačí ako videná — DrinksProvider dáva k dispozícii len
    // "vyčisti všetko naraz", nie odobratie jednej položky z fronty).
    final pending = context.watch<DrinksProvider>().pendingAchievements;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _index, children: _pages),
          if (pending.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AchievementUnlockOverlay(
                key: ValueKey(pending.first.id),
                achievement: pending.first,
                onDismiss: () =>
                    context.read<DrinksProvider>().clearPendingAchievements(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: loc.nav_home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            activeIcon: const Icon(Icons.account_balance_wallet),
            label: loc.support_tooltip,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.leaderboard),
            label: loc.leaderboard,
          ),
          if (_kShowContactTab)
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              activeIcon: const Icon(Icons.account_balance_wallet),
              label: loc.navContact,
            ),
        ],
      ),
    );
  }
}
