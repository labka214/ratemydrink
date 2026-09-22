import 'package:flutter/material.dart';
import '../enums/drink_type.dart';
import '../../l10n/app_localizations.dart';

IconData categoryIcon(DrinkType type) {
  switch (type) {
    case DrinkType.rum:
      return Icons.liquor;
    case DrinkType.whiskey:
      return Icons.local_bar;
  }
}

String categoryLabel(AppLocalizations loc, DrinkType type) {
  switch (type) {
    case DrinkType.rum:
      return loc.category_rum;
    case DrinkType.whiskey:
      return loc.category_whiskey;
  }
}
