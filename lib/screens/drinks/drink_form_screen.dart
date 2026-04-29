import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/enums/drink_type.dart';
import '../../l10n/app_localizations.dart';
import '../../models/drink_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/drinks_provider.dart';
import '../widgets/star_rating_widget.dart';

class DrinkFormScreen extends StatefulWidget {
  final DrinkType drinkType;
  final DrinkModel? existingDrink; // null = nový záznam, not null = editácia

  const DrinkFormScreen({
    super.key,
    required this.drinkType,
    this.existingDrink,
  });

  @override
  State<DrinkFormScreen> createState() => _DrinkFormScreenState();
}

class _DrinkFormScreenState extends State<DrinkFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Kontroléry
  late final TextEditingController _nameController;
  late final TextEditingController _countryController;
  late final TextEditingController _alcoholController;
  late final TextEditingController _urlController;
  late final TextEditingController _priceController;
  late final TextEditingController _noteController;

  double _rating = 3.0;
  DrinkSubtype? _selectedSubtype;
  String _selectedCurrency = 'EUR';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  bool get _isEditing => widget.existingDrink != null;

  @override
  void initState() {
    super.initState();
    final d = widget.existingDrink;
    _nameController = TextEditingController(text: d?.name ?? '');
    _countryController = TextEditingController(text: d?.country ?? '');
    _alcoholController = TextEditingController(
      text: d?.alcohol != null ? d!.alcohol!.toString() : '',
    );
    _urlController = TextEditingController(text: d?.url ?? '');
    _priceController = TextEditingController(
      text: d?.price != null ? d!.price!.toString() : '',
    );
    _noteController = TextEditingController(text: d?.note ?? '');
    _rating = d?.rating ?? 3.0;
    _selectedCurrency = d?.currency ?? 'EUR';
    _selectedDate = d?.date ?? DateTime.now();

    // Nastav subtype ak existuje
    if (d?.subtype != null) {
      try {
        _selectedSubtype = DrinkSubtype.values.firstWhere(
          (s) => s.firestoreValue == d!.subtype,
        );
      } catch (_) {
        _selectedSubtype = null;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _alcoholController.dispose();
    _urlController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.background,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.validation_required)),
      );
      return;
    }

    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();
    final drinksProvider = context.read<DrinksProvider>();
    final userId = authProvider.userId;

    if (userId == null) {
      setState(() => _isSaving = false);
      return;
    }

    // Limit kontrola (iba pri novom zázname)
    if (!_isEditing) {
      final count = drinksProvider.allDrinks
          .where((d) => d.type == widget.drinkType)
          .length;
      if (count >= AppConstants.freeTierLimit) {
        setState(() => _isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.free_limit_reached),
            ),
          );
        }
        return;
      }
    }

    final drink = DrinkModel(
      id: widget.existingDrink?.id,
      type: widget.drinkType,
      name: _nameController.text.trim(),
      rating: _rating,
      country: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
      alcohol: double.tryParse(_alcoholController.text.trim()),
      subtype: _selectedSubtype?.firestoreValue,
      date: _selectedDate,
      url: _urlController.text.trim().isEmpty
          ? null
          : _urlController.text.trim(),
      price: double.tryParse(_priceController.text.trim()),
      currency: _selectedCurrency,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      imageUrl: widget.existingDrink?.imageUrl,
      isFavorite: widget.existingDrink?.isFavorite ?? false,
      createdAt: widget.existingDrink?.createdAt ?? DateTime.now(),
    );

    try {
      if (_isEditing) {
        await drinksProvider.updateDrink(userId, drink);
      } else {
        await drinksProvider.addDrink(userId, drink);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final subtypes = widget.drinkType.subtypes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          _isEditing ? loc.btn_edit : loc.btn_add,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Hodnotenie ---
              _SectionLabel(loc.field_rating),
              const SizedBox(height: 8),
              Center(
                child: StarRatingWidget(
                  rating: _rating,
                  itemSize: 44,
                  onRatingUpdate: (val) => setState(() => _rating = val),
                ),
              ),
              const SizedBox(height: 20),

              // --- Názov ---
              _buildTextField(
                controller: _nameController,
                label: loc.field_name,
                required: true,
                loc: loc,
              ),
              const SizedBox(height: 14),

              // --- Podkategória ---
              _SectionLabel(loc.field_subtype),
              const SizedBox(height: 6),
              DropdownButtonFormField<DrinkSubtype?>(
                value: _selectedSubtype,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration(),
                items: [
                  DropdownMenuItem<DrinkSubtype?>(
                    value: null,
                    child: Text(
                      '— ${loc.field_subtype} —',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  ...subtypes.map((subtype) {
                    return DropdownMenuItem<DrinkSubtype?>(
                      value: subtype,
                      child: Text(_getSubtypeLabel(context, subtype)),
                    );
                  }),
                ],
                onChanged: (val) => setState(() => _selectedSubtype = val),
              ),
              const SizedBox(height: 14),

              // --- Krajina ---
              _buildTextField(
                controller: _countryController,
                label: loc.field_country,
                loc: loc,
              ),
              const SizedBox(height: 14),

              // --- Alkohol ---
              _buildTextField(
                controller: _alcoholController,
                label: loc.field_alcohol,
                keyboardType: TextInputType.number,
                isNumber: true,
                loc: loc,
              ),
              const SizedBox(height: 14),

              // --- Dátum ---
              _SectionLabel(loc.field_date),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: _inputDecoration(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('d. M. yyyy').format(_selectedDate),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      const Icon(Icons.calendar_today,
                          color: AppColors.textSecondary, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // --- Cena + Mena ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      controller: _priceController,
                      label: loc.field_price,
                      keyboardType: TextInputType.number,
                      isNumber: true,
                      loc: loc,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(loc.field_currency),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedCurrency,
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(
                              color: AppColors.textPrimary),
                          decoration: _inputDecoration(),
                          items: AppConstants.currencies
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCurrency = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // --- URL ---
              _buildTextField(
                controller: _urlController,
                label: loc.field_url,
                keyboardType: TextInputType.url,
                loc: loc,
              ),
              const SizedBox(height: 14),

              // --- Poznámka ---
              _buildTextField(
                controller: _noteController,
                label: loc.field_note,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                loc: loc,
              ),
              const SizedBox(height: 28),

              // --- Tlačidlá ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.textSecondary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(loc.btn_cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.background,
                              ),
                            )
                          : Text(
                              loc.btn_save,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    bool isNumber = false,
    int maxLines = 1,
    required AppLocalizations loc,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration(),
          validator: (val) {
            if (required && (val == null || val.trim().isEmpty)) {
              return loc.validation_required;
            }
            if (isNumber && val != null && val.trim().isNotEmpty) {
              if (double.tryParse(val.trim()) == null) {
                return loc.validation_number;
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  String _getSubtypeLabel(BuildContext context, DrinkSubtype subtype) {
    final loc = AppLocalizations.of(context)!;
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