import '../enums/drink_type.dart';
import '../../l10n/app_localizations.dart';

String subtypeLabel(AppLocalizations loc, DrinkSubtype subtype) {
  switch (subtype) {
    case DrinkSubtype.rumLight:
      return loc.subtype_rumLight;
    case DrinkSubtype.rumDark:
      return loc.subtype_rumDark;
    case DrinkSubtype.rumSpiced:
      return loc.subtype_rumSpiced;
    case DrinkSubtype.rumAgricole:
      return loc.subtype_rumAgricole;
    case DrinkSubtype.rumOverproof:
      return loc.subtype_rumOverproof;
    case DrinkSubtype.whiskeyScotch:
      return loc.subtype_whiskeyScotch;
    case DrinkSubtype.whiskeyIrish:
      return loc.subtype_whiskeyIrish;
    case DrinkSubtype.whiskeyBourbon:
      return loc.subtype_whiskeyBourbon;
    case DrinkSubtype.whiskeyJapanese:
      return loc.subtype_whiskeyJapanese;
    case DrinkSubtype.whiskeySingleMalt:
      return loc.subtype_whiskeySingleMalt;
    case DrinkSubtype.whiskeyBlended:
      return loc.subtype_whiskeyBlended;
  }
}

// Nájde DrinkSubtype podľa hodnoty uloženej vo Firestore (alebo null)
DrinkSubtype? subtypeFromFirestoreValue(String? value) {
  if (value == null) return null;
  for (final subtype in DrinkSubtype.values) {
    if (subtype.firestoreValue == value) return subtype;
  }
  return null;
}
