import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/drink_type.dart';
import '../../core/utils/category_ui.dart';
import '../../l10n/app_localizations.dart';
import '../drinks/drinks_list_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../stats/stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'RateMyDrink',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: AppColors.textSecondary),
            tooltip: loc.stats_title,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: AppColors.favorite),
            tooltip: loc.favorites,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle,
                color: AppColors.textSecondary),
            tooltip: loc.profile_tooltip,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app,
                color: AppColors.textSecondary),
            tooltip: loc.exit_app_tooltip,
            onPressed: () => SystemNavigator.pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CategoryButton(type: DrinkType.rum),
            const SizedBox(height: 16),
            _CategoryButton(type: DrinkType.whiskey),
          ],
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final DrinkType type;

  const _CategoryButton({required this.type});

  Color get _color {
    switch (type) {
      case DrinkType.rum:
        return AppColors.rumColor;
      case DrinkType.whiskey:
        return AppColors.whiskeyColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _color.withValues(alpha: 0.85),
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DrinksListScreen(drinkType: type),
            ),
          );
        },
        child: Text(
          '${type.emoji}   ${categoryLabel(AppLocalizations.of(context)!, type)}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}