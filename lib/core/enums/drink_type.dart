enum DrinkType {
  rum,
  whiskey;

  String get emoji {
    switch (this) {
      case DrinkType.rum:
        return '🥃';
      case DrinkType.whiskey:
        return '🥃';
    }
  }

  // Lokalizačný kľúč pre názov
  String get labelKey {
    switch (this) {
      case DrinkType.rum:
        return 'category_rum';
      case DrinkType.whiskey:
        return 'category_whiskey';
    }
  }

  // Hodnota ukladaná do Firestore
  String get firestoreValue => name;

  // Zoznam podkategórií pre daný typ
  List<DrinkSubtype> get subtypes {
    switch (this) {
      case DrinkType.rum:
        return [
          DrinkSubtype.rumLight,
          DrinkSubtype.rumDark,
          DrinkSubtype.rumSpiced,
          DrinkSubtype.rumAgricole,
          DrinkSubtype.rumOverproof,
        ];
      case DrinkType.whiskey:
        return [
          DrinkSubtype.whiskeyScotch,
          DrinkSubtype.whiskeyIrish,
          DrinkSubtype.whiskeyBourbon,
          DrinkSubtype.whiskeyJapanese,
          DrinkSubtype.whiskeySingleMalt,
          DrinkSubtype.whiskeyBlended,
        ];
    }
  }
}

enum DrinkSubtype {
  // Rum
  rumLight,
  rumDark,
  rumSpiced,
  rumAgricole,
  rumOverproof,
  // Whiskey
  whiskeyScotch,
  whiskeyIrish,
  whiskeyBourbon,
  whiskeyJapanese,
  whiskeySingleMalt,
  whiskeyBlended;

  // Hodnota ukladaná do Firestore
  String get firestoreValue => name;

  // Lokalizačný kľúč
  String get labelKey => 'subtype_$name';

  // Hlavná kategória, do ktorej podtyp patrí
  DrinkType get category {
    if (name.startsWith('rum')) return DrinkType.rum;
    return DrinkType.whiskey;
  }
}
