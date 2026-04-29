import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/drink_type.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/drinks_provider.dart';
import '../widgets/drink_card.dart';
import 'drink_form_screen.dart';
import 'drink_detail_screen.dart';
import 'drink_filter_screen.dart';

class DrinksListScreen extends StatefulWidget {
  final DrinkType drinkType;

  const DrinksListScreen({super.key, required this.drinkType});

  @override
  State<DrinksListScreen> createState() => _DrinksListScreenState();
}

class _DrinksListScreenState extends State<DrinksListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userId;
      if (userId != null) {
        context.read<DrinksProvider>().loadDrinks(userId, widget.drinkType);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final drinksProvider = context.watch<DrinksProvider>();
    final userId = context.read<AuthProvider>().userId;

    final allDrinks = drinksProvider.drinks
        .where((d) => d.type == widget.drinkType)
        .where((d) =>
    _searchQuery.isEmpty ||
        d.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          '${widget.drinkType.emoji}  ${widget.drinkType.name[0].toUpperCase()}${widget.drinkType.name.substring(1)}',
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
                  builder: (_) => const DrinkFilterScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DrinkFormScreen(drinkType: widget.drinkType),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: loc.search_hint,
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon:
                const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Zoznam
          Expanded(
            child: drinksProvider.isLoading
                ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
                : allDrinks.isEmpty
                ? Center(
              child: Text(
                loc.no_drinks,
                style: const TextStyle(
                    color: AppColors.textSecondary),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: allDrinks.length,
              itemBuilder: (context, index) {
                final drink = allDrinks[index];
                return DrinkCard(
                  drink: drink,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DrinkDetailScreen(drink: drink),
                      ),
                    );
                  },
                  onFavoriteToggle: () {
                    if (userId != null && drink.id != null) {
                      context.read<DrinksProvider>().toggleFavorite(
                                      userId,
                                      drink.id!,
                                      !drink.isFavorite,
                                    );
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}