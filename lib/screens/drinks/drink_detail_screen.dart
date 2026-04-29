import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/drink_type.dart';
import '../../l10n/app_localizations.dart';
import '../../models/drink_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/drinks_provider.dart';
import 'drink_form_screen.dart';

class DrinkDetailScreen extends StatefulWidget {
  final DrinkModel drink;

  const DrinkDetailScreen({super.key, required this.drink});

  @override
  State<DrinkDetailScreen> createState() => _DrinkDetailScreenState();
}

class _DrinkDetailScreenState extends State<DrinkDetailScreen> {
  late DrinkModel _drink;

  @override
  void initState() {
    super.initState();
    _drink = widget.drink;
  }

  String _getSubtypeLabel(BuildContext context, String? firestoreValue) {
    if (firestoreValue == null) return '';
    final loc = AppLocalizations.of(context)!;
    try {
      final subtype = DrinkSubtype.values.firstWhere(
        (s) => s.firestoreValue == firestoreValue,
      );
      switch (subtype) {
        case DrinkSubtype.rumDark: return loc.subtype_rumDark;
        case DrinkSubtype.rumWhite: return loc.subtype_rumWhite;
        case DrinkSubtype.rumGold: return loc.subtype_rumGold;
        case DrinkSubtype.rumSpiced: return loc.subtype_rumSpiced;
        case DrinkSubtype.rumFlavoured: return loc.subtype_rumFlavoured;
        case DrinkSubtype.rumAged: return loc.subtype_rumAged;
        case DrinkSubtype.beerLight: return loc.subtype_beerLight;
        case DrinkSubtype.beerDark: return loc.subtype_beerDark;
        case DrinkSubtype.beerAle: return loc.subtype_beerAle;
        case DrinkSubtype.beerLager: return loc.subtype_beerLager;
        case DrinkSubtype.beerSpecial: return loc.subtype_beerSpecial;
        case DrinkSubtype.whiskeySingleMalt: return loc.subtype_whiskeySingleMalt;
        case DrinkSubtype.whiskeyBlended: return loc.subtype_whiskeyBlended;
        case DrinkSubtype.whiskeyBourbon: return loc.subtype_whiskeyBourbon;
        case DrinkSubtype.whiskeyScotch: return loc.subtype_whiskeyScotch;
        case DrinkSubtype.whiskeyFlavoured: return loc.subtype_whiskeyFlavoured;
        case DrinkSubtype.wineWhiteDry: return loc.subtype_wineWhiteDry;
        case DrinkSubtype.wineWhiteSemiDry: return loc.subtype_wineWhiteSemiDry;
        case DrinkSubtype.wineWhiteSemiSweet: return loc.subtype_wineWhiteSemiSweet;
        case DrinkSubtype.wineWhiteSweet: return loc.subtype_wineWhiteSweet;
        case DrinkSubtype.wineRoseDry: return loc.subtype_wineRoseDry;
        case DrinkSubtype.wineRoseSemiDry: return loc.subtype_wineRoseSemiDry;
        case DrinkSubtype.wineRoseSemiSweet: return loc.subtype_wineRoseSemiSweet;
        case DrinkSubtype.wineRedDry: return loc.subtype_wineRedDry;
        case DrinkSubtype.wineRedSemiDry: return loc.subtype_wineRedSemiDry;
        case DrinkSubtype.wineRedSemiSweet: return loc.subtype_wineRedSemiSweet;
      }
    } catch (_) {
      return firestoreValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          _drink.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DrinkFormScreen(
                    drinkType: _drink.type,
                    existingDrink: _drink,
                  ),
                ),
              );
              // Po návrate z editácie načítame aktuálny drink z providera
              if (context.mounted) {
                final updated = context
                    .read<DrinksProvider>()
                    .allDrinks  // ← zmenené z .drinks na .allDrinks
                    .where((d) => d.id == _drink.id)
                    .firstOrNull;
                if (updated != null) {
                  setState(() {
                    _drink = updated;
                  });
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context, loc),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hodnotenie
            Center(
              child: RatingBarIndicator(
                rating: _drink.rating,
                itemBuilder: (_, __) =>
                    const Icon(Icons.star_rounded, color: AppColors.star),
                itemCount: 5,
                itemSize: 40,
              ),
            ),
            Center(
              child: Text(
                '${_drink.rating} / 5',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Údaje
            _DetailRow(
              icon: Icons.local_bar,
              label: loc.field_name,
              value: _drink.name,
            ),
            if (_drink.subtype != null)
              _DetailRow(
                icon: Icons.category,
                label: loc.field_subtype,
                value: _getSubtypeLabel(context, _drink.subtype),
              ),
            if (_drink.country != null)
              _DetailRow(
                icon: Icons.location_on,
                label: loc.field_country,
                value: _drink.country!,
              ),
            if (_drink.alcohol != null)
              _DetailRow(
                icon: Icons.percent,
                label: loc.field_alcohol,
                value: '${_drink.alcohol} %',
              ),
            _DetailRow(
              icon: Icons.calendar_today,
              label: loc.field_date,
              value: DateFormat('d. M. yyyy').format(_drink.date),
            ),
            if (_drink.price != null)
              _DetailRow(
                icon: Icons.euro,
                label: loc.field_price,
                value: '${_drink.price!.toStringAsFixed(2)} ${_drink.currency}',
              ),
            if (_drink.url != null)
              _DetailRow(
                icon: Icons.link,
                label: loc.field_url,
                value: _drink.url!,
              ),
            if (_drink.note != null) ...[
              const SizedBox(height: 16),
              _SectionLabel(loc.field_note),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _drink.note!,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, AppLocalizations loc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          loc.btn_delete,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '${loc.btn_delete} "${_drink.name}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              loc.btn_cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final userId = context.read<AuthProvider>().userId;
      if (userId != null && _drink.id != null) {
        await context.read<DrinksProvider>().deleteDrink(userId, _drink.id!);
        if (context.mounted) Navigator.of(context).pop();
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}