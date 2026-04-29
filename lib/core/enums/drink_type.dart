enum DrinkType {
  rum,
  beer,
  whiskey,
  wine;

  String get emoji {
    switch (this) {
      case DrinkType.rum:
        return '🥃';
      case DrinkType.beer:
        return '🍺';
      case DrinkType.whiskey:
        return '🥃';
      case DrinkType.wine:
        return '🍷';
    }
  }

  // Lokalizačný kľúč pre názov
  String get labelKey {
    switch (this) {
      case DrinkType.rum:
        return 'category_rum';
      case DrinkType.beer:
        return 'category_beer';
      case DrinkType.whiskey:
        return 'category_whiskey';
      case DrinkType.wine:
        return 'category_wine';
    }
  }

  // Hodnota ukladaná do Firestore
  String get firestoreValue => name;

  // Zoznam podkategórií pre daný typ
  List<DrinkSubtype> get subtypes {
    switch (this) {
      case DrinkType.rum:
        return [
          DrinkSubtype.rumDark,
          DrinkSubtype.rumWhite,
          DrinkSubtype.rumGold,
          DrinkSubtype.rumSpiced,
          DrinkSubtype.rumFlavoured,
          DrinkSubtype.rumAged,
        ];
      case DrinkType.beer:
        return [
          DrinkSubtype.beerLight,
          DrinkSubtype.beerDark,
          DrinkSubtype.beerAle,
          DrinkSubtype.beerLager,
          DrinkSubtype.beerSpecial,
        ];
      case DrinkType.whiskey:
        return [
          DrinkSubtype.whiskeySingleMalt,
          DrinkSubtype.whiskeyBlended,
          DrinkSubtype.whiskeyBourbon,
          DrinkSubtype.whiskeyScotch,
          DrinkSubtype.whiskeyFlavoured,
        ];
      case DrinkType.wine:
        return [
          DrinkSubtype.wineWhiteDry,
          DrinkSubtype.wineWhiteSemiDry,
          DrinkSubtype.wineWhiteSemiSweet,
          DrinkSubtype.wineWhiteSweet,
          DrinkSubtype.wineRoseDry,
          DrinkSubtype.wineRoseSemiDry,
          DrinkSubtype.wineRoseSemiSweet,
          DrinkSubtype.wineRedDry,
          DrinkSubtype.wineRedSemiDry,
          DrinkSubtype.wineRedSemiSweet,
        ];
    }
  }
}

enum DrinkSubtype {
  // Rum
  rumDark,
  rumWhite,
  rumGold,
  rumSpiced,
  rumFlavoured,
  rumAged,
  // Beer
  beerLight,
  beerDark,
  beerAle,
  beerLager,
  beerSpecial,
  // Whiskey
  whiskeySingleMalt,
  whiskeyBlended,
  whiskeyBourbon,
  whiskeyScotch,
  whiskeyFlavoured,
  // Wine
  wineWhiteDry,
  wineWhiteSemiDry,
  wineWhiteSemiSweet,
  wineWhiteSweet,
  wineRoseDry,
  wineRoseSemiDry,
  wineRoseSemiSweet,
  wineRedDry,
  wineRedSemiDry,
  wineRedSemiSweet;

  // Hodnota ukladaná do Firestore
  String get firestoreValue => name;

  // Lokalizačný kľúč
  String get labelKey => 'subtype_$name';
}