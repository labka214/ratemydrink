import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String name;
  final String category;
  final String subtype;
  final String country;
  final String manufacturer;
  final double averageRating;
  final int ratingCount;

  const LeaderboardEntry({
    required this.name,
    required this.category,
    required this.subtype,
    required this.country,
    required this.manufacturer,
    required this.averageRating,
    required this.ratingCount,
  });
}

class LeaderboardService {
  // Agreguje dokumenty z `public_ratings` podľa názvu nápoja (case-insensitive)
  // — spoločná logika pre jednorazové aj real-time (stream) načítanie.
  static List<LeaderboardEntry> _aggregate(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String category,
    int limit,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final doc in docs) {
      final data = doc.data();
      final name = (data['drinkName'] as String? ?? '').trim();
      if (name.isEmpty) continue;
      grouped.putIfAbsent(name.toLowerCase(), () => []).add(data);
    }

    final entries = grouped.entries.map((e) {
      final ratings = e.value;
      final avgRating = ratings
              .map((d) => (d['rating'] as num?)?.toDouble() ?? 0.0)
              .reduce((a, b) => a + b) /
          ratings.length;
      final sample = ratings.first;
      return LeaderboardEntry(
        name: sample['drinkName'] as String? ?? '',
        category: category,
        subtype: sample['subtype'] as String? ?? '',
        country: sample['country'] as String? ?? '',
        manufacturer: sample['manufacturer'] as String? ?? '',
        averageRating: double.parse(avgRating.toStringAsFixed(1)),
        ratingCount: ratings.length,
      );
    }).toList();

    entries.sort((a, b) {
      final cmp = b.averageRating.compareTo(a.averageRating);
      if (cmp != 0) return cmp;
      return b.ratingCount.compareTo(
          a.ratingCount); // pri rovnakom priemere: viac hodnotení = vyššie
    });

    return entries.take(limit).toList();
  }

  // Jednorazové načítanie verejného rebríčka.
  static Future<List<LeaderboardEntry>> getTopDrinks({
    required String category, // 'rum' alebo 'whiskey'
    int limit = 50,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('public_ratings')
        .where('category', isEqualTo: category)
        .get();

    return _aggregate(snapshot.docs, category, limit);
  }

  // Real-time verzia — rebríček sa prepočíta automaticky pri každej zmene v
  // `public_ratings` (napr. po návrate na záložku), bez zastaraného
  // jednorazového Future výsledku.
  static Stream<List<LeaderboardEntry>> watchTopDrinks({
    required String category,
    int limit = 50,
  }) {
    return FirebaseFirestore.instance
        .collection('public_ratings')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => _aggregate(snapshot.docs, category, limit));
  }
}
