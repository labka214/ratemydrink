import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/drink_type.dart';
import '../../providers/auth_provider.dart';
import '../drinks/drinks_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () => authProvider.signOut(),
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
            _CategoryButton(type: DrinkType.beer),
            const SizedBox(height: 16),
            _CategoryButton(type: DrinkType.whiskey),
            const SizedBox(height: 16),
            _CategoryButton(type: DrinkType.wine),
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
      case DrinkType.beer:
        return AppColors.beerColor;
      case DrinkType.whiskey:
        return AppColors.whiskeyColor;
      case DrinkType.wine:
        return AppColors.wineColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _color.withOpacity(0.85),
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
          '${type.emoji}   ${type.name[0].toUpperCase()}${type.name.substring(1)}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}