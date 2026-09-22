import 'dart:io';
import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/enums/drink_type.dart';
import '../../core/utils/subtype_ui.dart';
import '../../data/countries.dart';
import '../../l10n/app_localizations.dart';
import '../../models/drink_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/drinks_provider.dart';
import '../../services/drinks_database_service.dart';
import '../../services/storage_service.dart';
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
  final StorageService _storageService = StorageService();

  // Kontroléry
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;
  late final TextEditingController _countryController;
  late final FocusNode _countryFocusNode;
  late final TextEditingController _manufacturerController;
  late final TextEditingController _alcoholController;
  late final TextEditingController _urlController;
  late final TextEditingController _priceController;
  late final TextEditingController _noteController;

  double _rating = 3.0;
  DrinkSubtype? _selectedSubtype;
  String _selectedCurrency = 'EUR';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  File? _pickedImage;

  List<DrinkSuggestion> _suggestions = [];
  bool _showSuggestions = false;
  int _searchToken = 0;

  bool _showCountrySuggestions = false;
  List<String> _countrySuggestions = [];

  bool get _isEditing => widget.existingDrink != null;

  @override
  void initState() {
    super.initState();
    final d = widget.existingDrink;
    _nameController = TextEditingController(text: d?.name ?? '');
    _nameFocusNode = FocusNode();
    _nameFocusNode.addListener(_handleNameFocusChange);
    _countryController = TextEditingController(text: d?.country ?? '');
    _countryFocusNode = FocusNode();
    _manufacturerController =
        TextEditingController(text: d?.manufacturer ?? '');
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

    _countryController.addListener(() {
      final query = _countryController.text.trim().toLowerCase();
      if (query.isEmpty) {
        setState(() {
          _showCountrySuggestions = false;
          _countrySuggestions = [];
        });
        return;
      }
      final results = kCountries
          .where((c) => c.toLowerCase().contains(query))
          .toList();
      setState(() {
        _countrySuggestions = results;
        _showCountrySuggestions = results.isNotEmpty;
      });
    });
  }

  void _handleNameFocusChange() {
    if (!_nameFocusNode.hasFocus && _showSuggestions) {
      setState(() => _showSuggestions = false);
    }
  }

  Future<void> _onNameChanged(String value) async {
    final token = ++_searchToken;
    if (value.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final results = await DrinksDatabaseService.search(
      value,
      category: widget.drinkType.firestoreValue,
    );
    if (!mounted || token != _searchToken) return;
    setState(() {
      _suggestions = results;
      _showSuggestions = results.isNotEmpty;
    });
  }

  void _selectSuggestion(DrinkSuggestion option) {
    setState(() {
      _nameController.text = option.name;
      final subtype = subtypeFromFirestoreValue(option.subtype);
      if (subtype != null) _selectedSubtype = subtype;
      _countryController.text = option.country;
      _manufacturerController.text = option.manufacturer;
      // % alkoholu a hodnotenie zámerne nevypĺňame.
      _showSuggestions = false;
      _showCountrySuggestions = false;
      _countrySuggestions = [];
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _nameFocusNode.removeListener(_handleNameFocusChange);
    _nameController.dispose();
    _nameFocusNode.dispose();
    _countryController.dispose();
    _countryFocusNode.dispose();
    _manufacturerController.dispose();
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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.validation_required)),
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

    final drinkId =
        widget.existingDrink?.id ?? drinksProvider.newDrinkId(userId);

    String? imageUrl = widget.existingDrink?.imageUrl;
    if (_pickedImage != null) {
      try {
        imageUrl = await _storageService.uploadDrinkImage(
          userId,
          drinkId,
          _pickedImage!,
        );
      } catch (e) {
        debugPrint('Image upload failed: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.image_upload_error),
            ),
          );
          setState(() => _isSaving = false);
        }
        return;
      }
    }

    final drink = DrinkModel(
      id: drinkId,
      type: widget.drinkType,
      name: _nameController.text.trim(),
      rating: _rating,
      country: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
      manufacturer: _manufacturerController.text.trim().isEmpty
          ? null
          : _manufacturerController.text.trim(),
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
      imageUrl: imageUrl,
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
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 100;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
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
        physics: (_showSuggestions || _showCountrySuggestions)
            ? const NeverScrollableScrollPhysics()
            : const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).padding.bottom,
        ),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              _showSuggestions = false;
              _showCountrySuggestions = false;
            });
          },
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

                // --- Fotka ---
                _SectionLabel(loc.field_image),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              image: _pickedImage != null
                                  ? DecorationImage(
                                      image: FileImage(_pickedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : (widget.existingDrink?.imageUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            widget.existingDrink!.imageUrl!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null),
                            ),
                            child: (_pickedImage == null &&
                                    widget.existingDrink?.imageUrl == null)
                                ? const Icon(Icons.add_a_photo,
                                    color: AppColors.textSecondary, size: 28)
                                : null,
                          ),
                        ),
                        if (_pickedImage != null)
                          Positioned(
                            top: -8,
                            right: -8,
                            child: Tooltip(
                              message: loc.btn_cancel,
                              child: GestureDetector(
                                onTap: () => setState(() => _pickedImage = null),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.textSecondary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: Text(loc.btn_pick_image),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Názov (s autocomplete našepkávačom) ---
                _SectionLabel(loc.field_name),
                const SizedBox(height: 6),
                _buildNameField(loc, keyboardVisible),
                const SizedBox(height: 14),

                // --- Podkategória ---
                _SectionLabel(loc.field_subtype),
                const SizedBox(height: 6),
                DropdownButtonFormField<DrinkSubtype?>(
                  initialValue: _selectedSubtype,
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
                        child: Text(subtypeLabel(loc, subtype)),
                      );
                    }),
                  ],
                  onChanged: (val) => setState(() => _selectedSubtype = val),
                ),
                const SizedBox(height: 14),

                // --- Krajina (s autocomplete našepkávačom) ---
                _SectionLabel(loc.field_country),
                const SizedBox(height: 6),
                _buildCountryField(loc, keyboardVisible),
                const SizedBox(height: 14),

                // --- Výrobca ---
                _buildTextField(
                  controller: _manufacturerController,
                  label: loc.manufacturer,
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
                            initialValue: _selectedCurrency,
                            dropdownColor: AppColors.surface,
                            style: const TextStyle(color: AppColors.textPrimary),
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
      ),
    );
  }

  Widget _buildNameField(AppLocalizations loc, bool keyboardVisible) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration(),
          onChanged: _onNameChanged,
          validator: (val) => (val == null || val.trim().isEmpty)
              ? loc.validation_required
              : null,
        ),
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: BoxConstraints(
              maxHeight: min(
                _suggestions.length * 72.0,
                keyboardVisible ? 250.0 : 350.0,
              ),
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4),
              ],
            ),
            child: Scrollbar(
              thumbVisibility: true,
              interactive: false,
              thickness: 4.0,
              radius: const Radius.circular(2),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) => true,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final option = _suggestions[index];
                    return ListTile(
                      title: Text(
                        option.name,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        _suggestionSubtitle(loc, option),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () => _selectSuggestion(option),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCountryField(AppLocalizations loc, bool keyboardVisible) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _countryController,
          focusNode: _countryFocusNode,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration().copyWith(
            suffix: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                'EN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          onChanged: (_) {}, // listener handles it
          onTap: () {
            final query = _countryController.text.trim().toLowerCase();
            if (query.isNotEmpty) {
              final results = kCountries
                  .where((c) => c.toLowerCase().contains(query))
                  .toList();
              setState(() {
                _countrySuggestions = results;
                _showCountrySuggestions = results.isNotEmpty;
              });
            }
          },
        ),
        if (_showCountrySuggestions)
          Container(
            constraints: BoxConstraints(
              maxHeight: keyboardVisible ? 180 : 260,
            ),
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.2),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) => true,
              child: Scrollbar(
                thumbVisibility: true,
                interactive: false,
                thickness: 4.0,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _countrySuggestions.length,
                  itemBuilder: (ctx, i) {
                    final country = _countrySuggestions[i];
                    return ListTile(
                      dense: true,
                      title: Text(
                        country,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      onTap: () {
                        _countryController.text = country;
                        _countryFocusNode.unfocus();
                        setState(() {
                          _showCountrySuggestions = false;
                          _countrySuggestions = [];
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _suggestionSubtitle(AppLocalizations loc, DrinkSuggestion option) {
    final subtype = subtypeFromFirestoreValue(option.subtype);
    final subtypeText =
        subtype != null ? subtypeLabel(loc, subtype) : option.subtype;
    return [subtypeText, option.country, option.manufacturer]
        .where((s) => s.isNotEmpty)
        .join(' · ');
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
        borderSide:
            BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary),
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
