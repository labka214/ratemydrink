import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/drink_type.dart';
import '../../core/utils/category_ui.dart';
import '../../core/utils/subtype_ui.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/drinks_provider.dart';

class DrinkFilterScreen extends StatelessWidget {
  // Ak je zadaný, zobrazia sa len podtypy tejto kategórie.
  // Ak je null (napr. z Obľúbených), zobrazia sa všetky kategórie zoskupené.
  final DrinkType? drinkType;
  final bool showFavoritesToggle;

  const DrinkFilterScreen({
    super.key,
    this.drinkType,
    this.showFavoritesToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final drinksProvider = context.watch<DrinksProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          loc.btn_filter,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          0,
          8,
          0,
          8 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          _SortTile(
            label: loc.filter_date_new,
            option: SortOption.dateDesc,
            groupValue: drinksProvider.sortOption,
            onTap: () => drinksProvider.setSortOption(SortOption.dateDesc),
          ),
          _SortTile(
            label: loc.filter_date_old,
            option: SortOption.dateAsc,
            groupValue: drinksProvider.sortOption,
            onTap: () => drinksProvider.setSortOption(SortOption.dateAsc),
          ),
          _SortTile(
            label: loc.filter_rating_high,
            option: SortOption.ratingDesc,
            groupValue: drinksProvider.sortOption,
            onTap: () => drinksProvider.setSortOption(SortOption.ratingDesc),
          ),
          _SortTile(
            label: loc.filter_rating_low,
            option: SortOption.ratingAsc,
            groupValue: drinksProvider.sortOption,
            onTap: () => drinksProvider.setSortOption(SortOption.ratingAsc),
          ),
          _SortTile(
            label: loc.filter_price_high,
            option: SortOption.priceDesc,
            groupValue: drinksProvider.sortOption,
            onTap: () => drinksProvider.setSortOption(SortOption.priceDesc),
          ),
          _SortTile(
            label: loc.filter_price_low,
            option: SortOption.priceAsc,
            groupValue: drinksProvider.sortOption,
            onTap: () => drinksProvider.setSortOption(SortOption.priceAsc),
          ),
          if (showFavoritesToggle) ...[
            const Divider(color: AppColors.surface, height: 32),
            SwitchListTile(
              activeThumbColor: AppColors.primary,
              title: Text(
                loc.favorites,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              value: drinksProvider.showFavoritesOnly,
              onChanged: (_) => drinksProvider.toggleFavoritesOnly(),
            ),
          ],
          const Divider(color: AppColors.surface, height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              loc.field_subtype,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          ..._buildSubtypeTiles(loc, drinksProvider),
        ],
      ),
    );
  }

  List<Widget> _buildSubtypeTiles(
      AppLocalizations loc, DrinksProvider drinksProvider) {
    final types = drinkType != null ? [drinkType!] : DrinkType.values;
    final showGroupHeaders = drinkType == null;

    final tiles = <Widget>[];
    for (final type in types) {
      if (showGroupHeaders) {
        tiles.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(categoryIcon(type),
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  categoryLabel(loc, type),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      for (final subtype in type.subtypes) {
        final selected = drinksProvider.subtypeFilter == subtype.firestoreValue;
        tiles.add(
          _SubtypeTile(
            label: subtypeLabel(loc, subtype),
            selected: selected,
            onTap: () => drinksProvider
                .setSubtypeFilter(selected ? null : subtype.firestoreValue),
          ),
        );
      }
    }
    return tiles;
  }
}

class _SubtypeTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SubtypeTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      trailing: selected ? Icon(Icons.check, color: AppColors.primary) : null,
      onTap: onTap,
    );
  }
}

class _SortTile extends StatelessWidget {
  final String label;
  final SortOption option;
  final SortOption groupValue;
  final VoidCallback onTap;

  const _SortTile({
    required this.label,
    required this.option,
    required this.groupValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = option == groupValue;
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      trailing: selected ? Icon(Icons.check, color: AppColors.primary) : null,
      onTap: onTap,
    );
  }
}
