import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';

class SettingsProvider extends ChangeNotifier {
  Locale? _locale;

  // Téma
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  // Akcentová farba (predvolená: červená)
  Color _accentColor = const Color(0xFFE53935);
  Color get accentColor => _accentColor;

  // Dostupné akcentové farby
  static const List<Color> availableAccentColors = [
    Color(0xFFE53935), // Červená (predvolená)
    Color(0xFFFFB300), // Zlatá/Amber
    Color(0xFF1E88E5), // Modrá
    Color(0xFF43A047), // Zelená
    Color(0xFF8E24AA), // Fialová
    Color(0xFFFF6D00), // Oranžová
  ];

  SettingsProvider({String? initialLocale})
      : _locale = initialLocale != null ? Locale(initialLocale) : null;

  Locale? get locale => _locale;

  Future<void> setLocale(String localeCode) async {
    _locale = Locale(localeCode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', localeCode);
  }

  // Načítanie témy a akcentovej farby z SharedPreferences (volané pri štarte appky)
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex =
        prefs.getInt('themeMode') ?? 2; // 0=system,1=light,2=dark
    _themeMode = ThemeMode.values[themeModeIndex];

    final colorValue = prefs.getInt('accentColor') ?? 0xFFE53935;
    _accentColor = Color(colorValue);
    AppColors.updateAccent(_accentColor);

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    AppColors.updateAccent(color);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColor', color.toARGB32());
  }
}
