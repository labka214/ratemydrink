import 'package:flutter/material.dart';

class AppColors {
  static const Color _defaultPrimary =
      Color(0xFF8B1A1A); // pôvodná tmavočervená

  // Akcentová farba — nekonštantná zámerne, aby ju vedel SettingsProvider
  // za behu prepísať cez updateAccent() podľa výberu používateľa.
  static Color primary = _defaultPrimary;

  static const Color secondary = Color(0xFFD4A017); // zlatá (rum/pivo)
  static const Color background = Color(0xFF1C1C1C); // tmavé pozadie
  static const Color surface = Color(0xFF2A2A2A); // karty
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color star =
      Color(0xFFFFD700); // hviezdičky — vždy zlaté, nesleduje akcent
  static const Color favorite = Color(0xFFE91E63); // obľúbené (ružová/červená)

  // Farby kategórií
  static const Color rumColor = Color(0xFF8B4513);
  static const Color whiskeyColor = Color(0xFFB8860B);

  // Nastaví akcentovú (primary) farbu appky naprieč tlačidlami/ikonami/okrajmi.
  // Volá SettingsProvider pri štarte (loadSettings) a pri každej zmene výberu.
  static void updateAccent(Color color) {
    primary = color;
  }
}
