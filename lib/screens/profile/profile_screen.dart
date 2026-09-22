import 'dart:math' show min;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/drink_type.dart';
import '../../core/utils/category_ui.dart';
import '../../l10n/app_localizations.dart';
import '../../models/achievement.dart';
import '../../models/drink_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/drinks_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/achievement_definitions.dart';
import '../../services/achievement_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/badge_item.dart';
import '../auth/login_screen.dart';
import '../badges/badges_screen.dart';
import '../drinks/drinks_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isSigningIn = false;
  bool _isSaving = false;
  bool _isLoadingProfile = false;
  Map<DrinkType, int>? _categoryCounts;

  List<DrinkModel> _allDrinks = [];
  Set<String> _earnedIds = {};
  List<String> _earnedOrder = [];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadProfile(
          user.uid,
          googleName: user.displayName,
          googleEmail: user.email,
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile(String userId,
      {String? googleName, String? googleEmail}) async {
    setState(() => _isLoadingProfile = true);

    final profile = await _firestoreService.getUserProfile(userId);
    final counts = await _firestoreService.getCategoryCounts(userId);
    final allDrinks = await _firestoreService.getAllDrinksOnce(userId);
    final earnedOrder = await AchievementService.loadEarnedOrdered();

    if (!mounted) return;
    setState(() {
      _nameController.text =
          (profile?['displayName'] as String?) ?? googleName ?? '';
      _emailController.text =
          (profile?['email'] as String?) ?? googleEmail ?? '';
      _phoneController.text = (profile?['phone'] as String?) ?? '';
      _categoryCounts = counts;
      _allDrinks = allDrinks;
      _earnedOrder = earnedOrder;
      _earnedIds = AchievementService.calculateEarned(allDrinks);
      _isLoadingProfile = false;
    });
  }

  // Zoradenie pre horizontálny náhľad: najprv odomknuté (najnovšie prvé,
  // podľa poradia z AchievementService.loadEarnedOrdered), potom zamknuté
  // zoradené podľa toho, ako blízko sú k splneniu.
  List<AchievementDefinition> _sortedAchievementsForDisplay() {
    AchievementDefinition? findById(String id) {
      for (final a in AchievementDefinitions.allAchievements) {
        if (a.id == id) return a;
      }
      return null;
    }

    final earnedDefs = _earnedOrder.reversed
        .map(findById)
        .whereType<AchievementDefinition>()
        .toList();

    final lockedDefs = AchievementDefinitions.allAchievements
        .where((a) => !_earnedIds.contains(a.id))
        .toList()
      ..sort((a, b) {
        final pa = a.targetCount != null
            ? AchievementService.getProgress(_allDrinks, a) / a.targetCount!
            : 0.0;
        final pb = b.targetCount != null
            ? AchievementService.getProgress(_allDrinks, b) / b.targetCount!
            : 0.0;
        return pb.compareTo(pa);
      });

    return [...earnedDefs, ...lockedDefs];
  }

  Future<void> _saveProfile(String userId) async {
    setState(() => _isSaving = true);
    try {
      await _firestoreService.saveUserProfile(
        userId,
        displayName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profile_save)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _signIn() async {
    setState(() => _isSigningIn = true);
    final success = await context.read<AuthProvider>().signInWithGoogle();
    if (!mounted) return;
    setState(() => _isSigningIn = false);

    if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.login_error)),
      );
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user != null) {
      await _loadProfile(
        user.uid,
        googleName: user.displayName,
        googleEmail: user.email,
      );
    }
  }

  Future<void> _signOut() async {
    context.read<DrinksProvider>().clear();
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildAvatar(User? user) {
    final photoUrl = user?.photoURL;
    return CircleAvatar(
      radius: 48,
      backgroundColor: AppColors.surface,
      backgroundImage:
          photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
      child: photoUrl == null
          ? const Icon(Icons.person, size: 48, color: AppColors.textSecondary)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().user;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          loc.profile_title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.textSecondary),
              tooltip: loc.logout,
              onPressed: _signOut,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user == null) ...[
              Center(child: _buildAvatar(null)),
              const SizedBox(height: 24),
              if (_isSigningIn)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                )
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Image.network(
                    'https://www.google.com/favicon.ico',
                    height: 24,
                  ),
                  label: Text(
                    loc.login_google,
                    style: const TextStyle(fontSize: 16),
                  ),
                  onPressed: _signIn,
                ),
            ] else ...[
              Center(child: _buildAvatar(user)),
              const SizedBox(height: 24),
              if (_isLoadingProfile)
                Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              else ...[
                _ProfileField(
                  controller: _nameController,
                  label: loc.profile_name,
                ),
                const SizedBox(height: 12),
                _ProfileField(
                  controller: _emailController,
                  label: loc.profile_email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _ProfileField(
                  controller: _phoneController,
                  label: loc.profile_phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(loc.profile_save),
                  onPressed: _isSaving ? null : () => _saveProfile(user.uid),
                ),
              ],
              const SizedBox(height: 32),
              _SectionLabel(loc.profile_my_ratings),
              const SizedBox(height: 8),
              ...DrinkType.values.map((type) {
                final count = _categoryCounts?[type] ?? 0;
                return _CategoryCountRow(
                  type: type,
                  label: categoryLabel(loc, type),
                  count: count,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DrinksListScreen(drinkType: type),
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionLabel(loc.badges_title),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BadgesScreen()),
                    ),
                    child: Text(loc.badges_view_all),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Builder(builder: (context) {
                final sorted = _sortedAchievementsForDisplay();
                final visibleCount = min(7, sorted.length);
                return SizedBox(
                  height: 128,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: visibleCount,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final achievement = sorted[index];
                      final isEarned = _earnedIds.contains(achievement.id);
                      final progress = AchievementService.getProgress(
                          _allDrinks, achievement);
                      return BadgeItem(
                        achievement: achievement,
                        isEarned: isEarned,
                        progress: progress,
                        circleSize: 60,
                      );
                    },
                  ),
                );
              }),
            ],
            const SizedBox(height: 32),
            _SectionLabel(loc.appearance_title),
            const SizedBox(height: 16),
            // Farba je pred Témou — akcentová farba je momentálne jediná
            // reálne funkčná časť sekcie Vzhľad (pozri poznámku nižšie).
            Text(
              loc.accent_color_label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: SettingsProvider.availableAccentColors.map((color) {
                final isSelected =
                    settings.accentColor.toARGB32() == color.toARGB32();
                return GestureDetector(
                  onTap: () => settings.setAccentColor(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Prepínač Témy je dočasne skrytý z UI (kód zachovaný) — appka
            // číta farby priamo z AppColors, nie z Theme.of(context), takže
            // Svetlá/Systém téma by zatiaľ nemala reálny vizuálny efekt.
            // Text(
            //   loc.theme_label,
            //   style: const TextStyle(
            //     color: AppColors.textSecondary,
            //     fontSize: 13,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
            // const SizedBox(height: 8),
            // SegmentedButton<ThemeMode>(
            //   style: SegmentedButton.styleFrom(
            //     backgroundColor: AppColors.surface,
            //     foregroundColor: AppColors.textSecondary,
            //     selectedBackgroundColor: AppColors.primary,
            //     selectedForegroundColor: AppColors.textPrimary,
            //   ),
            //   segments: [
            //     ButtonSegment(
            //       value: ThemeMode.light,
            //       icon: const Icon(Icons.light_mode),
            //       label: Text(loc.theme_light),
            //     ),
            //     ButtonSegment(
            //       value: ThemeMode.system,
            //       icon: const Icon(Icons.brightness_auto),
            //       label: Text(loc.theme_system),
            //     ),
            //     ButtonSegment(
            //       value: ThemeMode.dark,
            //       icon: const Icon(Icons.dark_mode),
            //       label: Text(loc.theme_dark),
            //     ),
            //   ],
            //   selected: {settings.themeMode},
            //   onSelectionChanged: (selected) =>
            //       settings.setThemeMode(selected.first),
            // ),
            // const SizedBox(height: 6),
            // Text(
            //   loc.theme_light_note,
            //   style: const TextStyle(
            //     color: AppColors.textSecondary,
            //     fontSize: 12,
            //   ),
            // ),
            if (user != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: Text(loc.profile_logout),
                onPressed: _signOut,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  const _ProfileField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
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
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _CategoryCountRow extends StatelessWidget {
  final DrinkType type;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _CategoryCountRow({
    required this.type,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(categoryIcon(type), color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$label · $count',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

