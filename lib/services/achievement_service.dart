import 'package:shared_preferences/shared_preferences.dart';
import '../core/enums/drink_type.dart';
import '../models/achievement.dart';
import '../models/drink_model.dart';
import 'achievement_definitions.dart';

class AchievementService {
  static const _prefsKey = 'earned_achievements';

  // Vypočítaj ktoré odznaky sú splnené na základe VŠETKÝCH nápojov používateľa
  // (naprieč kategóriami — volajúci musí dodať kompletný zoznam, nie len
  // aktuálne načítanú kategóriu z DrinksProvider).
  static Set<String> calculateEarned(List<DrinkModel> drinks) {
    final earned = <String>{};
    final rumDrinks = drinks.where((d) => d.type == DrinkType.rum).toList();
    final wskDrinks = drinks.where((d) => d.type == DrinkType.whiskey).toList();
    final rumCount = rumDrinks.length;
    final wskCount = wskDrinks.length;
    final countries = drinks
        .map((d) => (d.country ?? '').trim().toLowerCase())
        .where((c) => c.isNotEmpty)
        .toSet();
    final rumSubtypes =
        rumDrinks.map((d) => d.subtype).whereType<String>().toSet();
    final wskSubtypes =
        wskDrinks.map((d) => d.subtype).whereType<String>().toSet();

    // Počet unikátnych subtypes podľa reálneho DrinkType enumu v appke.
    final totalRumSubtypes = DrinkType.rum.subtypes.length;
    final totalWskSubtypes = DrinkType.whiskey.subtypes.length;

    for (final a in AchievementDefinitions.allAchievements) {
      switch (a.id) {
        // Rum count
        case 'rum_1':
          if (rumCount >= 1) earned.add(a.id);
          break;
        case 'rum_5':
          if (rumCount >= 5) earned.add(a.id);
          break;
        case 'rum_10':
          if (rumCount >= 10) earned.add(a.id);
          break;
        case 'rum_25':
          if (rumCount >= 25) earned.add(a.id);
          break;
        case 'rum_50':
          if (rumCount >= 50) earned.add(a.id);
          break;
        case 'rum_100':
          if (rumCount >= 100) earned.add(a.id);
          break;
        case 'rum_150':
          if (rumCount >= 150) earned.add(a.id);
          break;
        case 'rum_200':
          if (rumCount >= 200) earned.add(a.id);
          break;
        case 'rum_250':
          if (rumCount >= 250) earned.add(a.id);
          break;
        // Whiskey count
        case 'wsk_1':
          if (wskCount >= 1) earned.add(a.id);
          break;
        case 'wsk_5':
          if (wskCount >= 5) earned.add(a.id);
          break;
        case 'wsk_10':
          if (wskCount >= 10) earned.add(a.id);
          break;
        case 'wsk_25':
          if (wskCount >= 25) earned.add(a.id);
          break;
        case 'wsk_50':
          if (wskCount >= 50) earned.add(a.id);
          break;
        case 'wsk_100':
          if (wskCount >= 100) earned.add(a.id);
          break;
        case 'wsk_150':
          if (wskCount >= 150) earned.add(a.id);
          break;
        case 'wsk_200':
          if (wskCount >= 200) earned.add(a.id);
          break;
        case 'wsk_250':
          if (wskCount >= 250) earned.add(a.id);
          break;
        // Krajiny
        case 'exp_3':
          if (countries.length >= 3) earned.add(a.id);
          break;
        case 'exp_7':
          if (countries.length >= 7) earned.add(a.id);
          break;
        case 'exp_12':
          if (countries.length >= 12) earned.add(a.id);
          break;
        // Subtypes
        case 'col_rum_3':
          if (rumSubtypes.length >= 3) earned.add(a.id);
          break;
        case 'col_rum_all':
          if (rumSubtypes.length >= totalRumSubtypes) earned.add(a.id);
          break;
        case 'col_wsk_3':
          if (wskSubtypes.length >= 3) earned.add(a.id);
          break;
        case 'col_wsk_all':
          if (wskSubtypes.length >= totalWskSubtypes) earned.add(a.id);
          break;
        // Hodnotiteľ
        case 'tst_critic':
          if (drinks.any((d) => d.rating <= 2)) earned.add(a.id);
          break;
        case 'tst_perfect':
          if (drinks.any((d) => d.rating >= 5)) earned.add(a.id);
          break;
        case 'tst_photo':
          if (drinks.any((d) => d.imageUrl != null && d.imageUrl!.isNotEmpty)) {
            earned.add(a.id);
          }
          break;
        case 'tst_notes':
          if (drinks
                  .where((d) => d.note != null && d.note!.trim().isNotEmpty)
                  .length >=
              10) {
            earned.add(a.id);
          }
          break;
      }
    }
    return earned;
  }

  // Uloží do SharedPreferences. Zachováva poradie predchádzajúceho zápisu a
  // nové id pridá na koniec — vďaka tomu vieme neskôr zistiť poradie
  // odomknutia (pozri loadEarnedOrdered), hoci loadEarned() vracia len Set.
  static Future<void> saveEarned(Set<String> earned) async {
    final prefs = await SharedPreferences.getInstance();
    final existingOrder = prefs.getStringList(_prefsKey) ?? [];
    final merged = [
      ...existingOrder.where(earned.contains),
      ...earned.where((id) => !existingOrder.contains(id)),
    ];
    await prefs.setStringList(_prefsKey, merged);
  }

  // Načítaj z SharedPreferences
  static Future<Set<String>> loadEarned() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_prefsKey) ?? []).toSet();
  }

  // Rovnaké dáta ako loadEarned(), ale ako List v poradí odomknutia
  // (najstaršie prvé) — používa ProfileScreen na zoradenie "najnovšie prvé".
  static Future<List<String>> loadEarnedOrdered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefsKey) ?? [];
  }

  // Porovnaj staré vs nové — vráti nové odznaky
  static Set<String> findNewlyEarned(
      Set<String> previous, Set<String> current) {
    return current.difference(previous);
  }

  // Progres pre progress bar (count-based odznaky)
  static int getProgress(List<DrinkModel> drinks, AchievementDefinition a) {
    final rumDrinks = drinks.where((d) => d.type == DrinkType.rum).toList();
    final wskDrinks = drinks.where((d) => d.type == DrinkType.whiskey).toList();
    final countries = drinks
        .map((d) => (d.country ?? '').trim().toLowerCase())
        .where((c) => c.isNotEmpty)
        .toSet()
        .length;

    switch (a.category) {
      case AchievementCategory.rum:
        return rumDrinks.length;
      case AchievementCategory.whiskey:
        return wskDrinks.length;
      case AchievementCategory.explorer:
        return countries;
      case AchievementCategory.collector:
        final source = a.id.startsWith('col_rum') ? rumDrinks : wskDrinks;
        return source.map((d) => d.subtype).whereType<String>().toSet().length;
      case AchievementCategory.taster:
        return 0;
    }
  }
}
