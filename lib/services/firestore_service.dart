import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/drink_model.dart';
import '../core/enums/drink_type.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Referencia na kolekciu nápojov konkrétneho používateľa
  CollectionReference<Map<String, dynamic>> _drinksRef(String userId) {
    return _db.collection('users').doc(userId).collection('drinks');
  }

  // Načítaj všetky nápoje daného typu (real-time stream)
  Stream<List<DrinkModel>> getDrinksStream(String userId, DrinkType type) {
    return _drinksRef(userId)
        .where('type', isEqualTo: type.firestoreValue)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => DrinkModel.fromFirestore(doc)).toList());
  }

  // Počet nápojov daného typu (pre FREE limit)
  Future<int> getDrinksCount(String userId, DrinkType type) async {
    final snapshot = await _drinksRef(userId)
        .where('type', isEqualTo: type.firestoreValue)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // Skontroluj či používateľ dosiahol FREE limit
  Future<bool> isFreeLimitReached(String userId, DrinkType type) async {
    final count = await getDrinksCount(userId, type);
    return count >= AppConstants.freeTierLimit;
  }

  // Pridaj nový nápoj
  Future<void> addDrink(String userId, DrinkModel drink) async {
    await _drinksRef(userId).add(drink.toFirestore());
  }

  // Aktualizuj existujúci nápoj
  Future<void> updateDrink(String userId, DrinkModel drink) async {
    if (drink.id == null) return;
    await _drinksRef(userId).doc(drink.id).update(drink.toFirestore());
  }

  // Vymaž nápoj
  Future<void> deleteDrink(String userId, String drinkId) async {
    await _drinksRef(userId).doc(drinkId).delete();
  }

  // Prepni obľúbené
  Future<void> toggleFavorite(
      String userId, String drinkId, bool isFavorite) async {
    await _drinksRef(userId)
        .doc(drinkId)
        .update({'isFavorite': isFavorite});
  }

  // Načítaj jeden nápoj podľa ID
  Future<DrinkModel?> getDrink(String userId, String drinkId) async {
    final doc = await _drinksRef(userId).doc(drinkId).get();
    if (!doc.exists) return null;
    return DrinkModel.fromFirestore(doc);
  }

  // Štatistiky
  Future<Map<String, dynamic>> getStats(String userId, DrinkType type) async {
    final snapshot = await _drinksRef(userId)
        .where('type', isEqualTo: type.firestoreValue)
        .get();

    if (snapshot.docs.isEmpty) return {};

    final drinks =
    snapshot.docs.map((doc) => DrinkModel.fromFirestore(doc)).toList();

    final avgRating =
        drinks.map((d) => d.rating).reduce((a, b) => a + b) / drinks.length;

    final bestDrink =
    drinks.reduce((a, b) => a.rating >= b.rating ? a : b);

    final drinksWithPrice = drinks.where((d) => d.price != null).toList();
    final mostExpensive = drinksWithPrice.isEmpty
        ? null
        : drinksWithPrice.reduce((a, b) => a.price! >= b.price! ? a : b);

    return {
      'avgRating': avgRating,
      'bestDrink': bestDrink,
      'mostExpensive': mostExpensive,
      'totalCount': drinks.length,
    };
  }
}