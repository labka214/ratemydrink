import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/drink_model.dart';
import '../core/enums/drink_type.dart';
import 'storage_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  // Referencia na kolekciu nápojov konkrétneho používateľa
  CollectionReference<Map<String, dynamic>> _drinksRef(String userId) {
    return _db.collection('users').doc(userId).collection('drinks');
  }

  // Referencia na dokument profilu používateľa
  DocumentReference<Map<String, dynamic>> _userRef(String userId) {
    return _db.collection('users').doc(userId);
  }

  // Referencia na kolekciu verejných hodnotení (bez poznámok/fotiek/osobných údajov)
  CollectionReference<Map<String, dynamic>> get _publicRatingsRef =>
      _db.collection('public_ratings');

  // Deterministické ID verejného záznamu — jeden na dvojicu (používateľ, názov nápoja)
  String _publicRatingId(String userId, String drinkName) {
    final slug = drinkName
        .trim()
        .toLowerCase()
        .replaceAll('/', '_')
        .replaceAll(' ', '_');
    return '${userId}_$slug';
  }

  // Vytvor/prepíš verejný (anonymizovaný) záznam hodnotenia pre rebríček
  Future<void> _upsertPublicRating(String userId, DrinkModel drink) async {
    final id = _publicRatingId(userId, drink.name);
    await _publicRatingsRef.doc(id).set({
      'drinkName': drink.name,
      'category': drink.type.firestoreValue,
      'subtype': drink.subtype ?? '',
      'country': drink.country ?? '',
      'manufacturer': drink.manufacturer ?? '',
      'rating': drink.rating,
      'userId': userId,
    }, SetOptions(merge: false));
  }

  // Zmaž verejný záznam hodnotenia (ak existuje)
  Future<void> _deletePublicRating(String userId, String drinkName) async {
    final id = _publicRatingId(userId, drinkName);
    await _publicRatingsRef.doc(id).delete();
  }

  // Vygeneruj nové ID záznamu (bez zápisu) — potrebné pred uploadom fotky
  String newDrinkId(String userId) {
    return _drinksRef(userId).doc().id;
  }

  // Jednorazovo načíta VŠETKY nápoje používateľa naprieč kategóriami
  // (napr. pre výpočet odznakov, ktoré potrebujú kompletný obraz, nie len
  // aktuálne sledovanú kategóriu z DrinksProvider).
  Future<List<DrinkModel>> getAllDrinksOnce(String userId) async {
    final snapshot = await _drinksRef(userId).get();
    return snapshot.docs.map((doc) => DrinkModel.fromFirestore(doc)).toList();
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

  // Načítaj všetky obľúbené nápoje naprieč typmi (real-time stream)
  Stream<List<DrinkModel>> getFavoritesStream(String userId) {
    return _drinksRef(userId)
        .where('isFavorite', isEqualTo: true)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DrinkModel.fromFirestore(doc)).toList());
  }

  // Jednorazové načítanie obľúbených (bez realtime streamu)
  Future<List<DrinkModel>> getFavoritesOnce(String userId) async {
    final snapshot = await _drinksRef(userId)
        .where('isFavorite', isEqualTo: true)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => DrinkModel.fromFirestore(doc)).toList();
  }

  // Pridaj nový nápoj
  Future<void> addDrink(String userId, DrinkModel drink) async {
    final id = drink.id ?? newDrinkId(userId);
    await _drinksRef(userId).doc(id).set(drink.toFirestore());
    await _upsertPublicRating(userId, drink);
  }

  // Aktualizuj existujúci nápoj
  Future<void> updateDrink(String userId, DrinkModel drink) async {
    if (drink.id == null) return;
    final docRef = _drinksRef(userId).doc(drink.id);

    // Ak sa zmenil názov, verejný záznam má iné (nové) ID — starý treba zmazať,
    // inak by v public_ratings zostal osirotený duplicitný záznam.
    final previous = await docRef.get();
    final previousName = previous.data()?['name'] as String?;

    await docRef.update(drink.toFirestore());

    if (previousName != null && previousName != drink.name) {
      await _deletePublicRating(userId, previousName);
    }
    await _upsertPublicRating(userId, drink);
  }

  // Vymaž nápoj (vrátane fotky v Storage a verejného záznamu z rebríčka)
  Future<void> deleteDrink(String userId, String drinkId) async {
    final doc = await _drinksRef(userId).doc(drinkId).get();
    final name = doc.data()?['name'] as String?;
    final imageUrl = doc.data()?['imageUrl'] as String?;

    // Najprv zmaž fotku a verejný záznam — ešte kým dokument existuje.
    // Ak niektorý krok zlyhá (napr. výpadok siete), nápoj sa NEVYMAŽE
    // a používateľ môže skúsiť znova. Tým sa zabráni osiroteniu fotky.
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        await _storageService.deleteDrinkImage(userId, drinkId);
      } catch (_) {
        // Ak sa fotku nepodarí zmazať, pokračuj — Storage sa môže
        // čistiť neskôr manuálne alebo cez Firebase lifecycle rules.
      }
    }

    if (name != null) {
      try {
        await _deletePublicRating(userId, name);
      } catch (_) {
        // Verejný záznam je best-effort; zlyhanie neblokuje mazanie.
      }
    }

    // Samotný dokument vymažeme až na konci.
    await _drinksRef(userId).doc(drinkId).delete();
  }

  // Prepni obľúbené
  Future<void> toggleFavorite(
      String userId, String drinkId, bool isFavorite) async {
    await _drinksRef(userId).doc(drinkId).update({'isFavorite': isFavorite});
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

    final bestDrink = drinks.reduce((a, b) => a.rating >= b.rating ? a : b);

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

  // Počet hodnotení v každej kategórii
  Future<Map<DrinkType, int>> getCategoryCounts(String userId) async {
    final results = await Future.wait(DrinkType.values.map((type) async {
      final snapshot = await _drinksRef(userId)
          .where('type', isEqualTo: type.firestoreValue)
          .count()
          .get();
      return MapEntry(type, snapshot.count ?? 0);
    }));
    return Map.fromEntries(results);
  }

  // Načítaj profil používateľa (meno, email, telefón)
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _userRef(userId).get();
    return doc.data();
  }

  // Ulož/aktualizuj profil používateľa
  Future<void> saveUserProfile(
    String userId, {
    String? displayName,
    String? email,
    String? phone,
  }) async {
    await _userRef(userId).set({
      'displayName': displayName,
      'email': email,
      'phone': phone,
    }, SetOptions(merge: true));
  }

  // Uloží earned badge IDs do Firestore (users/{userId}/achievements)
  Future<void> saveAchievements(String userId, List<String> earned) async {
    await _userRef(userId).set(
      {'achievements': earned},
      SetOptions(merge: true),
    );
  }

  // Načíta earned badge IDs z Firestore (vráti prázdny List ak dokument
  // neexistuje alebo pole chýba)
  Future<List<String>> loadAchievements(String userId) async {
    final doc = await _userRef(userId).get();
    if (!doc.exists) return [];
    final data = doc.data() as Map<String, dynamic>?;
    final raw = data?['achievements'];
    if (raw is List) return List<String>.from(raw);
    return [];
  }

  // Odošli spätnú väzbu / kontaktný formulár
  Future<void> submitFeedback({
    String? userId,
    required String type,
    required String message,
    required String name,
    required String email,
    required String appVersion,
  }) async {
    await _db.collection('feedback').add({
      'userId': userId,
      'type': type,
      'message': message,
      'name': name,
      'email': email,
      'timestamp': FieldValue.serverTimestamp(),
      'appVersion': appVersion,
    });
  }
}
