import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DrinkSuggestion {
  final String name;
  final String category;
  final String subtype;
  final String country;
  final String manufacturer;

  const DrinkSuggestion({
    required this.name,
    required this.category,
    required this.subtype,
    required this.country,
    required this.manufacturer,
  });

  factory DrinkSuggestion.fromJson(Map<String, dynamic> json) {
    return DrinkSuggestion(
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      subtype: json['subtype'] as String? ?? '',
      country: json['country'] as String? ?? '',
      manufacturer: json['manufacturer'] as String? ?? '',
    );
  }
}

class DrinksDatabaseService {
  static List<DrinkSuggestion>? _cache;

  // Načíta a naparsuje JSON databázu z assets, len pri prvom použití.
  static Future<List<DrinkSuggestion>> _load() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString('assets/data/drinks_db.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    final drinks = decoded
        .map((e) => DrinkSuggestion.fromJson(e as Map<String, dynamic>))
        .toList();

    _cache = drinks;
    return drinks;
  }

  // Vyhľadá nápoje podľa názvu (case-insensitive), voliteľne obmedzené na kategóriu.
  static Future<List<DrinkSuggestion>> search(
    String query, {
    String? category,
  }) async {
    if (query.trim().isEmpty) return [];

    final all = await _load();
    final lowerQuery = query.toLowerCase();

    return all
        .where((d) =>
            d.name.toLowerCase().contains(lowerQuery) &&
            (category == null || d.category == category))
        .take(20)
        .toList();
  }
}
