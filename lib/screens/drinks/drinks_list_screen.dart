import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/drink_type.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/drinks_provider.dart';
import '../../services/export_service.dart';
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
  final ExportService _exportService = ExportService();
  String _searchQuery = '';

  Future<void> _exportCsv(
    AppLocalizations loc,
    DrinksProvider drinksProvider,
  ) async {
    final drinks = drinksProvider.drinks;
    if (drinks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.no_drinks)),
      );
      return;
    }

    try {
      await _exportService.exportDrinks(
        drinks: drinks,
        fileName: 'ratemydrink_${widget.drinkType.name}',
        shareText: loc.export_csv,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.export_error)),
        );
      }
    }
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
    // watch (nie read): hneď po Google prihlásení môže authStateChanges
    // (viď AuthProvider) doraziť s malým oneskorením za navigáciou na túto
    // obrazovku. Pri read() by userId ostal null navždy a loadDrinks by sa
    // nikdy nezavolalo → nekonečný spinner. Pri watch() sa obrazovka
    // prekreslí hneď ako userId dorazí a načítanie sa spustí dodatočne.
    final userId = context.watch<AuthProvider>().userId;

    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // loadDrinks má vlastný dedup guard (rovnaký userId+type sa
        // preskočí), takže opakované volanie pri každom rebuilde je bezpečné.
        context.read<DrinksProvider>().loadDrinks(userId, widget.drinkType);
      });
    }

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
            icon: const Icon(Icons.file_download_outlined,
                color: AppColors.textSecondary),
            tooltip: loc.export_csv_tooltip,
            onPressed: () => _exportCsv(loc, drinksProvider),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.textSecondary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      DrinkFilterScreen(drinkType: widget.drinkType),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: AppColors.primary),
            onPressed: () {
              // Bez forceRefresh: DrinksProvider už na tento typ počúva
              // realtime stream, ktorý pridaný záznam premietne sám —
              // vynútený reload by len zbytočne zrušil a znova naštartoval
              // stream a spôsobil krátke bliknutie zoznamu.
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
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : allDrinks.isEmpty
                    ? Center(
                        child: Text(
                          loc.no_drinks,
                          style:
                              const TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          12,
                          12,
                          12,
                          12 + MediaQuery.of(context).padding.bottom,
                        ),
                        itemCount: allDrinks.length,
                        itemBuilder: (context, index) {
                          final drink = allDrinks[index];
                          return DrinkCard(
                            drink: drink,
                            onTap: () {
                              // Rovnako bez forceRefresh — úpravu/vymazanie záznamu na
                              // detaile premietne existujúci realtime stream.
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
