import 'dart:async';
import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/drink_model.dart';
import '../core/enums/drink_type.dart';
import '../services/achievement_definitions.dart';
import '../services/achievement_service.dart';
import '../services/firestore_service.dart';

enum SortOption {
  dateDesc,
  dateAsc,
  ratingDesc,
  ratingAsc,
  priceDesc,
  priceAsc,
}

class DrinksProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<DrinkModel> _drinks = [];
  bool _isLoading = true;
  String? _errorMessage;
  SortOption _sortOption = SortOption.dateDesc;
  String _searchQuery = '';
  bool _showFavoritesOnly = false;
  String? _subtypeFilter;
  StreamSubscription? _subscription;

  // Kľúč "userId:type" pre kategóriu, ktorá je aktuálne načítaná/sledovaná.
  // Zabraňuje opakovanému rušeniu a nanovo spúšťaniu streamu (a tým aj
  // opakovanému zobrazeniu loadingu) pri každom vstupe na tú istú obrazovku.
  String? _loadedDrinksKey;

  List<DrinkModel> _favoriteDrinks = [];
  bool _isFavoritesLoading = true;
  StreamSubscription? _favoritesSubscription;

  List<AchievementDefinition> _pendingAchievements = [];
  List<AchievementDefinition> get pendingAchievements => _pendingAchievements;

  void clearPendingAchievements() {
    _pendingAchievements = [];
    notifyListeners();
  }

  // Prepočíta odznaky na základe VŠETKÝCH nápojov používateľa (naprieč
  // kategóriami — _drinks obsahuje len aktuálne sledovanú kategóriu, preto
  // sa tu vždy načíta čerstvý kompletný zoznam priamo z Firestore).
  Future<void> _checkAchievements(String userId) async {
    final allDrinks = await _firestoreService.getAllDrinksOnce(userId);
    final previous = await AchievementService.loadEarned();
    final current = AchievementService.calculateEarned(allDrinks);
    final newlyEarned = AchievementService.findNewlyEarned(previous, current);
    if (newlyEarned.isNotEmpty) {
      await AchievementService.saveEarned(current);
      _pendingAchievements = newlyEarned
          .map((id) => AchievementDefinitions.allAchievements
              .firstWhere((a) => a.id == id))
          .toList();
      notifyListeners();
    }
  }

  List<DrinkModel> get drinks => _applyFilters(_drinks);
  List<DrinkModel> get allDrinks => List.unmodifiable(_drinks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SortOption get sortOption => _sortOption;
  bool get showFavoritesOnly => _showFavoritesOnly;
  String? get subtypeFilter => _subtypeFilter;

  List<DrinkModel> get favoriteDrinks => _applyFilters(_favoriteDrinks);
  bool get isFavoritesLoading => _isFavoritesLoading;

  // Načítaj obľúbené nápoje naprieč všetkými typmi (real-time)
  void loadFavorites(String userId) {
    _favoritesSubscription?.cancel();
    _isFavoritesLoading = true;
    notifyListeners();

    _favoritesSubscription =
        _firestoreService.getFavoritesStream(userId).listen(
      (drinks) {
        _favoriteDrinks = drinks;
        _isFavoritesLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isFavoritesLoading = false;
        notifyListeners();
      },
    );
  }

  // Jednorazové (nie realtime) načítanie obľúbených — použité na "zahriatie"
  // dát hneď po prihlásení, aby sa pri otvorení Obľúbených nezobrazila prázdna obrazovka.
  Future<void> loadFavoritesOnce(String userId) async {
    try {
      _favoriteDrinks = await _firestoreService.getFavoritesOnce(userId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isFavoritesLoading = false;
      notifyListeners();
    }
  }

  // Vyčisti stav (napr. po odhlásení používateľa)
  void clear() {
    _subscription?.cancel();
    _favoritesSubscription?.cancel();
    _drinks = [];
    _favoriteDrinks = [];
    _searchQuery = '';
    _showFavoritesOnly = false;
    _subtypeFilter = null;
    _isLoading = true;
    _isFavoritesLoading = true;
    _errorMessage = null;
    _loadedDrinksKey = null;
    _pendingAchievements = [];
    notifyListeners();
  }

  // Načítaj nápoje (real-time). Ak je pre danú kombináciu userId+type
  // stream už aktívny, druhé a ďalšie volanie (napr. z initState pri
  // opätovnom vstupe na obrazovku) sa preskočí, aby sa nezrušil bežiaci
  // stream a neukázal loading nanovo. Vynútiť nové načítanie sa dá cez
  // forceRefresh: true.
  Future<void> loadDrinks(
    String userId,
    DrinkType type, {
    bool forceRefresh = false,
  }) async {
    final key = '$userId:${type.name}';
    debugPrint(
      'DrinksProvider.loadDrinks START key=$key forceRefresh=$forceRefresh '
      'current=$_loadedDrinksKey',
    );

    if (_loadedDrinksKey == key && !forceRefresh) {
      debugPrint('DrinksProvider.loadDrinks SKIP (už načítané) key=$key');
      return;
    }
    _loadedDrinksKey = key;

    await _subscription?.cancel();

    // Spinner zobraz len ak ešte nemáme žiadne dáta (prvé načítanie danej
    // kategórie). Pri forceRefresh na kategórii, ktorá už dáta má, by
    // opätovné nastavenie _isLoading = true krátko schovalo celý zoznam a
    // spôsobilo viditeľné "preblikávanie" — stream nižšie aj tak dáta
    // aktualizuje bez potreby loadingu.
    if (_drinks.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    _subscription = _firestoreService.getDrinksStream(userId, type).listen(
      (drinks) {
        _drinks = drinks;
        _isLoading = false;
        notifyListeners();
        debugPrint(
          'DrinksProvider.loadDrinks END (data) key=$key count=${drinks.length}',
        );
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        _loadedDrinksKey = null;
        notifyListeners();
        debugPrint(
            'DrinksProvider.loadDrinks END (error) key=$key error=$error');
      },
    );
  }

  // Filtrovanie + triedenie (spoločné pre hlavný zoznam aj Obľúbené)
  List<DrinkModel> _applyFilters(List<DrinkModel> source) {
    List<DrinkModel> result = List.from(source);

    // Vyhľadávanie
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
              (d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Obľúbené
    if (_showFavoritesOnly) {
      result = result.where((d) => d.isFavorite).toList();
    }

    // Podtyp
    if (_subtypeFilter != null) {
      result = result.where((d) => d.subtype == _subtypeFilter).toList();
    }

    // Triedenie
    switch (_sortOption) {
      case SortOption.dateDesc:
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.dateAsc:
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.ratingDesc:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.ratingAsc:
        result.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case SortOption.priceDesc:
        result.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case SortOption.priceAsc:
        result.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
    }

    return result;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void toggleFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  void setSubtypeFilter(String? subtype) {
    _subtypeFilter = subtype;
    notifyListeners();
  }

  String newDrinkId(String userId) {
    return _firestoreService.newDrinkId(userId);
  }

  Future<void> addDrink(String userId, DrinkModel drink) async {
    await _firestoreService.addDrink(userId, drink);
    await _checkAchievements(userId);
  }

  Future<void> updateDrink(String userId, DrinkModel drink) async {
    await _firestoreService.updateDrink(userId, drink);
    await _checkAchievements(userId);
  }

  Future<void> deleteDrink(String userId, String drinkId) async {
    await _firestoreService.deleteDrink(userId, drinkId);
  }

  Future<void> toggleFavorite(
      String userId, String drinkId, bool isFavorite) async {
    // Optimistický update — prejaví sa v UI okamžite, bez čakania na Firestore.
    _applyFavoriteLocally(drinkId, isFavorite);
    notifyListeners();

    await _firestoreService.toggleFavorite(userId, drinkId, isFavorite);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _favoritesSubscription?.cancel();
    _isLoading = false;
    super.dispose();
  }

  void _applyFavoriteLocally(String drinkId, bool isFavorite) {
    final index = _drinks.indexWhere((d) => d.id == drinkId);
    if (index != -1) {
      _drinks[index] = _drinks[index].copyWith(isFavorite: isFavorite);
    }

    final favoriteIndex = _favoriteDrinks.indexWhere((d) => d.id == drinkId);
    if (isFavorite) {
      if (favoriteIndex != -1) {
        _favoriteDrinks[favoriteIndex] =
            _favoriteDrinks[favoriteIndex].copyWith(isFavorite: true);
      } else if (index != -1) {
        _favoriteDrinks = [_drinks[index], ..._favoriteDrinks];
      }
    } else if (favoriteIndex != -1) {
      _favoriteDrinks = List.from(_favoriteDrinks)..removeAt(favoriteIndex);
    }
  }
}
