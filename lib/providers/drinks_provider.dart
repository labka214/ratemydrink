import 'dart:async';
import 'package:flutter/material.dart';
import '../models/drink_model.dart';
import '../core/enums/drink_type.dart';
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
  bool _isLoading = false;
  String? _errorMessage;
  SortOption _sortOption = SortOption.dateDesc;
  String _searchQuery = '';
  bool _showFavoritesOnly = false;
  StreamSubscription? _subscription;

  List<DrinkModel> get drinks => _filteredAndSorted();
  List<DrinkModel> get allDrinks => List.unmodifiable(_drinks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SortOption get sortOption => _sortOption;
  bool get showFavoritesOnly => _showFavoritesOnly;

  // Načítaj nápoje (real-time)
  void loadDrinks(String userId, DrinkType type) {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = _firestoreService.getDrinksStream(userId, type).listen(
      (drinks) {
        _drinks = drinks;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Filtrovanie + triedenie
  List<DrinkModel> _filteredAndSorted() {
    List<DrinkModel> result = List.from(_drinks);

    // Vyhľadávanie
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((d) =>
              d.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Obľúbené
    if (_showFavoritesOnly) {
      result = result.where((d) => d.isFavorite).toList();
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

  Future<void> addDrink(String userId, DrinkModel drink) async {
    await _firestoreService.addDrink(userId, drink);
  }

  Future<void> updateDrink(String userId, DrinkModel drink) async {
    await _firestoreService.updateDrink(userId, drink);
  }

  Future<void> deleteDrink(String userId, String drinkId) async {
    await _firestoreService.deleteDrink(userId, drinkId);
  }

  Future<void> toggleFavorite(
      String userId, String drinkId, bool isFavorite) async {
    await _firestoreService.toggleFavorite(userId, drinkId, isFavorite);
  }

  Future<bool> isFreeLimitReached(String userId, DrinkType type) async {
    return await _firestoreService.isFreeLimitReached(userId, type);
  }
}