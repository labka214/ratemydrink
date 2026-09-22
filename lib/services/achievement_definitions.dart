import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/achievement.dart';

class AchievementDefinitions {
  // RUM (9 odznakov) — amber/zlatá paleta
  static const List<AchievementDefinition> rumAchievements = [
    AchievementDefinition(
        id: 'rum_1',
        name: 'Prvý dúšok',
        description: 'Ohodnoť 1 rum',
        emoji: '🌱',
        color: Color(0xFF66BB6A),
        category: AchievementCategory.rum,
        targetCount: 1),
    AchievementDefinition(
        id: 'rum_5',
        name: 'Rum Začiatočník',
        description: 'Ohodnoť 5 rumov',
        emoji: '🔰',
        color: Color(0xFFFFB300),
        category: AchievementCategory.rum,
        targetCount: 5),
    AchievementDefinition(
        id: 'rum_10',
        name: 'Rum Objaviteľ',
        description: 'Ohodnoť 10 rumov',
        emoji: '🗺️',
        color: Color(0xFFFF8F00),
        category: AchievementCategory.rum,
        targetCount: 10),
    AchievementDefinition(
        id: 'rum_25',
        name: 'Rum Znalec',
        description: 'Ohodnoť 25 rumov',
        emoji: '⚗️',
        color: Color(0xFFEF6C00),
        category: AchievementCategory.rum,
        targetCount: 25),
    AchievementDefinition(
        id: 'rum_50',
        name: 'Rum Explorátor',
        description: 'Ohodnoť 50 rumov',
        emoji: '🧭',
        color: Color(0xFFE64A19),
        category: AchievementCategory.rum,
        targetCount: 50),
    AchievementDefinition(
        id: 'rum_100',
        name: 'Rum Nadšenec',
        description: 'Ohodnoť 100 rumov',
        emoji: '🎖️',
        color: Color(0xFFD32F2F),
        category: AchievementCategory.rum,
        targetCount: 100),
    AchievementDefinition(
        id: 'rum_150',
        name: 'Rum Expert',
        description: 'Ohodnoť 150 rumov',
        emoji: '🏅',
        color: Color(0xFFC62828),
        category: AchievementCategory.rum,
        targetCount: 150),
    AchievementDefinition(
        id: 'rum_200',
        name: 'Rum Majster',
        description: 'Ohodnoť 200 rumov',
        emoji: '🥇',
        color: Color(0xFFFFD700),
        category: AchievementCategory.rum,
        targetCount: 200),
    AchievementDefinition(
        id: 'rum_250',
        name: 'Rum Legenda',
        description: 'Ohodnoť 250 rumov',
        emoji: '👑',
        color: Color(0xFFFFD700),
        category: AchievementCategory.rum,
        targetCount: 250),
  ];

  // WHISKEY (9 odznakov) — modrá paleta
  static const List<AchievementDefinition> whiskeyAchievements = [
    AchievementDefinition(
        id: 'wsk_1',
        name: 'Prvá whiskey',
        description: 'Ohodnoť 1 whiskey',
        emoji: '🌱',
        color: Color(0xFF66BB6A),
        category: AchievementCategory.whiskey,
        targetCount: 1),
    AchievementDefinition(
        id: 'wsk_5',
        name: 'Whiskey Začiatočník',
        description: 'Ohodnoť 5 whiskey',
        emoji: '🔰',
        color: Color(0xFF42A5F5),
        category: AchievementCategory.whiskey,
        targetCount: 5),
    AchievementDefinition(
        id: 'wsk_10',
        name: 'Whiskey Objaviteľ',
        description: 'Ohodnoť 10 whiskey',
        emoji: '🗺️',
        color: Color(0xFF1E88E5),
        category: AchievementCategory.whiskey,
        targetCount: 10),
    AchievementDefinition(
        id: 'wsk_25',
        name: 'Whiskey Znalec',
        description: 'Ohodnoť 25 whiskey',
        emoji: '⚗️',
        color: Color(0xFF1565C0),
        category: AchievementCategory.whiskey,
        targetCount: 25),
    AchievementDefinition(
        id: 'wsk_50',
        name: 'Whiskey Explorátor',
        description: 'Ohodnoť 50 whiskey',
        emoji: '🧭',
        color: Color(0xFF0D47A1),
        category: AchievementCategory.whiskey,
        targetCount: 50),
    AchievementDefinition(
        id: 'wsk_100',
        name: 'Whiskey Nadšenec',
        description: 'Ohodnoť 100 whiskey',
        emoji: '🎖️',
        color: Color(0xFF1A237E),
        category: AchievementCategory.whiskey,
        targetCount: 100),
    AchievementDefinition(
        id: 'wsk_150',
        name: 'Whiskey Expert',
        description: 'Ohodnoť 150 whiskey',
        emoji: '🏅',
        color: Color(0xFF283593),
        category: AchievementCategory.whiskey,
        targetCount: 150),
    AchievementDefinition(
        id: 'wsk_200',
        name: 'Whiskey Majster',
        description: 'Ohodnoť 200 whiskey',
        emoji: '🥇',
        color: Color(0xFFFFD700),
        category: AchievementCategory.whiskey,
        targetCount: 200),
    AchievementDefinition(
        id: 'wsk_250',
        name: 'Whiskey Legenda',
        description: 'Ohodnoť 250 whiskey',
        emoji: '👑',
        color: Color(0xFFFFD700),
        category: AchievementCategory.whiskey,
        targetCount: 250),
  ];

  // KRAJINY (3 odznaky) — zelená paleta
  static const List<AchievementDefinition> explorerAchievements = [
    AchievementDefinition(
        id: 'exp_3',
        name: 'Cestovateľ',
        description: 'Nápoje z 3 krajín',
        emoji: '🌍',
        color: Color(0xFF43A047),
        category: AchievementCategory.explorer,
        targetCount: 3),
    AchievementDefinition(
        id: 'exp_7',
        name: 'Svetobežník',
        description: 'Nápoje z 7 krajín',
        emoji: '✈️',
        color: Color(0xFF2E7D32),
        category: AchievementCategory.explorer,
        targetCount: 7),
    AchievementDefinition(
        id: 'exp_12',
        name: 'Globálny znalec',
        description: 'Nápoje z 12 krajín',
        emoji: '🌐',
        color: Color(0xFF1B5E20),
        category: AchievementCategory.explorer,
        targetCount: 12),
  ];

  // SUBTYPES (4 odznaky) — teal paleta.
  // Počet unikátnych DrinkSubtype hodnôt v appke: rum = 5, whiskey = 6
  // (pozri core/enums/drink_type.dart), preto col_rum_all/col_wsk_all
  // majú konkrétny targetCount namiesto null.
  static const List<AchievementDefinition> collectorAchievements = [
    AchievementDefinition(
        id: 'col_rum_3',
        name: 'Rum Gurmán',
        description: 'Ochutnaj 3 druhy rumu',
        emoji: '🎭',
        color: Color(0xFF00897B),
        category: AchievementCategory.collector,
        targetCount: 3),
    AchievementDefinition(
        id: 'col_rum_all',
        name: 'Rum Kolektor',
        description: 'Ochutnaj všetky druhy rumu',
        emoji: '🏆',
        color: Color(0xFF00695C),
        category: AchievementCategory.collector,
        targetCount: 5),
    AchievementDefinition(
        id: 'col_wsk_3',
        name: 'Whiskey Gurmán',
        description: 'Ochutnaj 3 druhy whiskey',
        emoji: '🎩',
        color: Color(0xFF00ACC1),
        category: AchievementCategory.collector,
        targetCount: 3),
    AchievementDefinition(
        id: 'col_wsk_all',
        name: 'Whiskey Kolektor',
        description: 'Ochutnaj všetky druhy whiskey',
        emoji: '🏅',
        color: Color(0xFF00838F),
        category: AchievementCategory.collector,
        targetCount: 6),
  ];

  // HODNOTITEĽ (4 odznaky) — fialová paleta
  static const List<AchievementDefinition> tasterAchievements = [
    AchievementDefinition(
        id: 'tst_critic',
        name: 'Kritik',
        description: 'Daj hodnotenie 1★ alebo 2★',
        emoji: '🔍',
        color: Color(0xFF8E24AA),
        category: AchievementCategory.taster,
        targetCount: null),
    AchievementDefinition(
        id: 'tst_perfect',
        name: 'Perfekcionista',
        description: 'Daj hodnotenie 5★',
        emoji: '💎',
        color: Color(0xFF6A1B9A),
        category: AchievementCategory.taster,
        targetCount: null),
    AchievementDefinition(
        id: 'tst_photo',
        name: 'Fotograf',
        description: 'Pridaj fotku k hodnoteniu',
        emoji: '📸',
        color: Color(0xFF4A148C),
        category: AchievementCategory.taster,
        targetCount: null),
    AchievementDefinition(
        id: 'tst_notes',
        name: 'Pisateľ',
        description: '10 hodnotení s poznámkou',
        emoji: '📝',
        color: Color(0xFF7B1FA2),
        category: AchievementCategory.taster,
        targetCount: 10),
  ];

  static const List<AchievementDefinition> allAchievements = [
    ...rumAchievements,
    ...whiskeyAchievements,
    ...explorerAchievements,
    ...collectorAchievements,
    ...tasterAchievements,
  ];

  static final Map<String, String Function(AppLocalizations)> _names = {
    'rum_1': (l) => l.badge_rum_1_name,
    'rum_5': (l) => l.badge_rum_5_name,
    'rum_10': (l) => l.badge_rum_10_name,
    'rum_25': (l) => l.badge_rum_25_name,
    'rum_50': (l) => l.badge_rum_50_name,
    'rum_100': (l) => l.badge_rum_100_name,
    'rum_150': (l) => l.badge_rum_150_name,
    'rum_200': (l) => l.badge_rum_200_name,
    'rum_250': (l) => l.badge_rum_250_name,
    'wsk_1': (l) => l.badge_wsk_1_name,
    'wsk_5': (l) => l.badge_wsk_5_name,
    'wsk_10': (l) => l.badge_wsk_10_name,
    'wsk_25': (l) => l.badge_wsk_25_name,
    'wsk_50': (l) => l.badge_wsk_50_name,
    'wsk_100': (l) => l.badge_wsk_100_name,
    'wsk_150': (l) => l.badge_wsk_150_name,
    'wsk_200': (l) => l.badge_wsk_200_name,
    'wsk_250': (l) => l.badge_wsk_250_name,
    'exp_3': (l) => l.badge_exp_3_name,
    'exp_7': (l) => l.badge_exp_7_name,
    'exp_12': (l) => l.badge_exp_12_name,
    'col_rum_3': (l) => l.badge_col_rum_3_name,
    'col_rum_all': (l) => l.badge_col_rum_all_name,
    'col_wsk_3': (l) => l.badge_col_wsk_3_name,
    'col_wsk_all': (l) => l.badge_col_wsk_all_name,
    'tst_critic': (l) => l.badge_tst_critic_name,
    'tst_perfect': (l) => l.badge_tst_perfect_name,
    'tst_photo': (l) => l.badge_tst_photo_name,
    'tst_notes': (l) => l.badge_tst_notes_name,
  };

  static final Map<String, String Function(AppLocalizations)> _descriptions = {
    'rum_1': (l) => l.badge_rum_1_desc,
    'rum_5': (l) => l.badge_rum_5_desc,
    'rum_10': (l) => l.badge_rum_10_desc,
    'rum_25': (l) => l.badge_rum_25_desc,
    'rum_50': (l) => l.badge_rum_50_desc,
    'rum_100': (l) => l.badge_rum_100_desc,
    'rum_150': (l) => l.badge_rum_150_desc,
    'rum_200': (l) => l.badge_rum_200_desc,
    'rum_250': (l) => l.badge_rum_250_desc,
    'wsk_1': (l) => l.badge_wsk_1_desc,
    'wsk_5': (l) => l.badge_wsk_5_desc,
    'wsk_10': (l) => l.badge_wsk_10_desc,
    'wsk_25': (l) => l.badge_wsk_25_desc,
    'wsk_50': (l) => l.badge_wsk_50_desc,
    'wsk_100': (l) => l.badge_wsk_100_desc,
    'wsk_150': (l) => l.badge_wsk_150_desc,
    'wsk_200': (l) => l.badge_wsk_200_desc,
    'wsk_250': (l) => l.badge_wsk_250_desc,
    'exp_3': (l) => l.badge_exp_3_desc,
    'exp_7': (l) => l.badge_exp_7_desc,
    'exp_12': (l) => l.badge_exp_12_desc,
    'col_rum_3': (l) => l.badge_col_rum_3_desc,
    'col_rum_all': (l) => l.badge_col_rum_all_desc,
    'col_wsk_3': (l) => l.badge_col_wsk_3_desc,
    'col_wsk_all': (l) => l.badge_col_wsk_all_desc,
    'tst_critic': (l) => l.badge_tst_critic_desc,
    'tst_perfect': (l) => l.badge_tst_perfect_desc,
    'tst_photo': (l) => l.badge_tst_photo_desc,
    'tst_notes': (l) => l.badge_tst_notes_desc,
  };

  static String localizedName(String id, AppLocalizations l10n) {
    final getter = _names[id];
    return getter != null ? getter(l10n) : id;
  }

  static String localizedDescription(String id, AppLocalizations l10n) {
    final getter = _descriptions[id];
    return getter != null ? getter(l10n) : '';
  }
}
