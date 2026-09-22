import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/drink_type.dart';
import '../../core/utils/category_ui.dart';
import '../../l10n/app_localizations.dart';
import '../../models/drink_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/drinks_provider.dart';
import '../widgets/drink_card.dart';
import '../drinks/drink_detail_screen.dart';
import '../drinks/drink_filter_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userId;
      if (userId != null) {
        context.read<DrinksProvider>().loadFavorites(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final drinksProvider = context.watch<DrinksProvider>();
    final userId = context.read<AuthProvider>().userId;
    final favorites = drinksProvider.favoriteDrinks;

    final grouped = <DrinkType, List<DrinkModel>>{
      for (final type in DrinkType.values)
        type: favorites.where((d) => d.type == type).toList(),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          loc.favorites,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.textSecondary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DrinkFilterScreen(
                    showFavoritesToggle: false,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: drinksProvider.isFavoritesLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : favorites.isEmpty
              ? Center(
                  child: Text(
                    loc.no_favorites,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    12,
                    12,
                    12 + MediaQuery.of(context).padding.bottom,
                  ),
                  children: [
                    for (final type in DrinkType.values)
                      if (grouped[type]!.isNotEmpty)
                        _CategorySection(
                          type: type,
                          label: categoryLabel(loc, type),
                          drinks: grouped[type]!,
                          onTapDrink: (drink) async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DrinkDetailScreen(drink: drink),
                              ),
                            );
                            if (userId != null && context.mounted) {
                              context
                                  .read<DrinksProvider>()
                                  .loadFavorites(userId);
                            }
                          },
                          onToggleFavorite: (drink) {
                            if (userId != null && drink.id != null) {
                              context.read<DrinksProvider>().toggleFavorite(
                                    userId,
                                    drink.id!,
                                    !drink.isFavorite,
                                  );
                            }
                          },
                        ),
                  ],
                ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final DrinkType type;
  final String label;
  final List<DrinkModel> drinks;
  final void Function(DrinkModel drink) onTapDrink;
  final void Function(DrinkModel drink) onToggleFavorite;

  const _CategorySection({
    required this.type,
    required this.label,
    required this.drinks,
    required this.onTapDrink,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          child: Row(
            children: [
              Icon(categoryIcon(type), color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.surface, height: 1),
        ...drinks.map(
          (drink) => DrinkCard(
            drink: drink,
            onTap: () => onTapDrink(drink),
            onFavoriteToggle: () => onToggleFavorite(drink),
          ),
        ),
      ],
    );
  }
}
