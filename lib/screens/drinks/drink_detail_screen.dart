import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/subtype_ui.dart';
import '../../l10n/app_localizations.dart';
import '../../models/drink_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/drinks_provider.dart';
import '../../widgets/share_card_preview_sheet.dart';
import '../widgets/star_rating_widget.dart';
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

  Future<void> _openShareSheet(AppLocalizations loc) async {
    // Ak je fotka, dotiahni ju vopred, aby bola v náhľade hneď hotová.
    final photoUrl = _drink.imageUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      await precacheImage(CachedNetworkImageProvider(photoUrl), context);
    }
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ShareCardPreviewSheet(
        drinkName: _drink.name,
        subtype: _getSubtypeLabel(context, _drink.subtype),
        country: _drink.country,
        manufacturer: _drink.manufacturer,
        rating: _drink.rating,
        photoUrl: _drink.imageUrl,
        category: _drink.type.firestoreValue,
      ),
    );
  }

  Future<void> _updateRating(double newRating) async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null || _drink.id == null) return;

    final previous = _drink;
    final updated = _drink.copyWith(rating: newRating);
    setState(() => _drink = updated);

    try {
      await context.read<DrinksProvider>().updateDrink(userId, updated);
    } catch (e) {
      if (mounted) {
        setState(() => _drink = previous);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba: $e')),
        );
      }
    }
  }

  String _getSubtypeLabel(BuildContext context, String? firestoreValue) {
    final subtype = subtypeFromFirestoreValue(firestoreValue);
    if (subtype == null) return firestoreValue ?? '';
    return subtypeLabel(AppLocalizations.of(context)!, subtype);
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
            icon: const Icon(Icons.share, color: AppColors.textSecondary),
            tooltip: loc.share_tooltip,
            onPressed: () => _openShareSheet(loc),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.primary),
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
                    .allDrinks // ← zmenené z .drinks na .allDrinks
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
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fotka
            if (_drink.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: _drink.imageUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 220,
                    color: AppColors.surface,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 220,
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.broken_image,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Hodnotenie
            Center(
              child: StarRatingWidget(
                rating: _drink.rating,
                itemSize: 40,
                onRatingUpdate: _updateRating,
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
            if (_drink.manufacturer != null && _drink.manufacturer!.isNotEmpty)
              _DetailRow(
                icon: Icons.factory,
                label: loc.manufacturer,
                value: _drink.manufacturer!,
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
