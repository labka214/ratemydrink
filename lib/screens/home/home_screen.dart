import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/drink_type.dart';
import '../../core/utils/category_ui.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../drinks/drinks_list_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../stats/stats_screen.dart';

void _showLanguageModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _LanguageOption(flag: '🇸🇰', label: 'Slovenčina', locale: 'sk'),
          const _LanguageOption(flag: '🇨🇿', label: 'Čeština', locale: 'cs'),
          const _LanguageOption(flag: '🇬🇧', label: 'English', locale: 'en'),
          const _LanguageOption(flag: '🇩🇪', label: 'Deutsch', locale: 'de'),
        ],
      ),
    ),
  );
}

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              final currentLocale = settings.locale?.languageCode ?? 'en';
              final flags = {
                'sk': '🇸🇰',
                'cs': '🇨🇿',
                'en': '🇬🇧',
                'de': '🇩🇪'
              };
              final labels = {
                'sk': 'Slovenčina',
                'cs': 'Čeština',
                'en': 'English',
                'de': 'Deutsch'
              };
              return GestureDetector(
                onTap: () => _showLanguageModal(context),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.language,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 5),
                      Text(
                        '${flags[currentLocale]}  ${labels[currentLocale]}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.expand_more,
                          size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
          },
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

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final String locale;

  const _LanguageOption(
      {required this.flag, required this.label, required this.locale});

  @override
  Widget build(BuildContext context) {
    final currentLocale =
        context.watch<SettingsProvider>().locale?.languageCode ?? 'en';
    final isSelected = currentLocale == locale;

    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing:
          isSelected ? const Icon(Icons.check, color: AppColors.secondary) : null,
      onTap: () async {
        await context.read<SettingsProvider>().setLocale(locale);
        if (context.mounted) Navigator.of(context).pop();
      },
    );
  }
}