import 'package:flutter/material.dart';

enum AchievementCategory { rum, whiskey, explorer, taster, collector }

class AchievementDefinition {
  final String id;
  final String name; // slovenský názov
  final String description; // podmienka (napr. "Ohodnoť 10 rumov")
  final String emoji; // emoji ikona
  final Color color; // farba kruhu (earned)
  final AchievementCategory category;
  final int? targetCount; // pre count-based odznaky

  const AchievementDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.color,
    required this.category,
    this.targetCount,
  });
}

class EarnedAchievement {
  final String id;
  final DateTime earnedAt;

  const EarnedAchievement({required this.id, required this.earnedAt});
}
