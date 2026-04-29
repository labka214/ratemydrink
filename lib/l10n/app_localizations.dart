import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_sk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('sk')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'RateMyDrink'**
  String get appName;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get select_language;

  /// No description provided for @category_rum.
  ///
  /// In en, this message translates to:
  /// **'Rum'**
  String get category_rum;

  /// No description provided for @category_beer.
  ///
  /// In en, this message translates to:
  /// **'Beer'**
  String get category_beer;

  /// No description provided for @category_whiskey.
  ///
  /// In en, this message translates to:
  /// **'Whiskey'**
  String get category_whiskey;

  /// No description provided for @category_wine.
  ///
  /// In en, this message translates to:
  /// **'Wine'**
  String get category_wine;

  /// No description provided for @btn_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btn_save;

  /// No description provided for @btn_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btn_cancel;

  /// No description provided for @btn_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get btn_edit;

  /// No description provided for @btn_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btn_delete;

  /// No description provided for @btn_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get btn_add;

  /// No description provided for @btn_filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get btn_filter;

  /// No description provided for @btn_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get btn_back;

  /// No description provided for @field_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get field_name;

  /// No description provided for @field_rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get field_rating;

  /// No description provided for @field_country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get field_country;

  /// No description provided for @field_alcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol (%)'**
  String get field_alcohol;

  /// No description provided for @field_subtype.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get field_subtype;

  /// No description provided for @field_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get field_date;

  /// No description provided for @field_url.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get field_url;

  /// No description provided for @field_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get field_price;

  /// No description provided for @field_note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get field_note;

  /// No description provided for @field_image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get field_image;

  /// No description provided for @field_currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get field_currency;

  /// No description provided for @validation_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validation_required;

  /// No description provided for @validation_number.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get validation_number;

  /// No description provided for @login_google.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get login_google;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @free_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'You have reached the limit of 10 records. Upgrade to the paid version.'**
  String get free_limit_reached;

  /// No description provided for @upgrade_to_premium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgrade_to_premium;

  /// No description provided for @export_csv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get export_csv;

  /// No description provided for @stats_title.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats_title;

  /// No description provided for @stats_avg_rating.
  ///
  /// In en, this message translates to:
  /// **'Average rating'**
  String get stats_avg_rating;

  /// No description provided for @stats_best_drink.
  ///
  /// In en, this message translates to:
  /// **'Best drink'**
  String get stats_best_drink;

  /// No description provided for @stats_most_expensive.
  ///
  /// In en, this message translates to:
  /// **'Most expensive drink'**
  String get stats_most_expensive;

  /// No description provided for @filter_rating_high.
  ///
  /// In en, this message translates to:
  /// **'Rating: highest'**
  String get filter_rating_high;

  /// No description provided for @filter_rating_low.
  ///
  /// In en, this message translates to:
  /// **'Rating: lowest'**
  String get filter_rating_low;

  /// No description provided for @filter_price_high.
  ///
  /// In en, this message translates to:
  /// **'Price: highest'**
  String get filter_price_high;

  /// No description provided for @filter_price_low.
  ///
  /// In en, this message translates to:
  /// **'Price: lowest'**
  String get filter_price_low;

  /// No description provided for @filter_date_new.
  ///
  /// In en, this message translates to:
  /// **'Date: newest'**
  String get filter_date_new;

  /// No description provided for @filter_date_old.
  ///
  /// In en, this message translates to:
  /// **'Date: oldest'**
  String get filter_date_old;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favorites;

  /// No description provided for @no_drinks.
  ///
  /// In en, this message translates to:
  /// **'No records'**
  String get no_drinks;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
  String get search_hint;

  /// No description provided for @subtype_rumDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get subtype_rumDark;

  /// No description provided for @subtype_rumWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get subtype_rumWhite;

  /// No description provided for @subtype_rumGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get subtype_rumGold;

  /// No description provided for @subtype_rumSpiced.
  ///
  /// In en, this message translates to:
  /// **'Spiced'**
  String get subtype_rumSpiced;

  /// No description provided for @subtype_rumFlavoured.
  ///
  /// In en, this message translates to:
  /// **'Flavoured'**
  String get subtype_rumFlavoured;

  /// No description provided for @subtype_rumAged.
  ///
  /// In en, this message translates to:
  /// **'Aged'**
  String get subtype_rumAged;

  /// No description provided for @subtype_beerLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get subtype_beerLight;

  /// No description provided for @subtype_beerDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get subtype_beerDark;

  /// No description provided for @subtype_beerAle.
  ///
  /// In en, this message translates to:
  /// **'Ale'**
  String get subtype_beerAle;

  /// No description provided for @subtype_beerLager.
  ///
  /// In en, this message translates to:
  /// **'Lager'**
  String get subtype_beerLager;

  /// No description provided for @subtype_beerSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get subtype_beerSpecial;

  /// No description provided for @subtype_whiskeySingleMalt.
  ///
  /// In en, this message translates to:
  /// **'Single Malt'**
  String get subtype_whiskeySingleMalt;

  /// No description provided for @subtype_whiskeyBlended.
  ///
  /// In en, this message translates to:
  /// **'Blended'**
  String get subtype_whiskeyBlended;

  /// No description provided for @subtype_whiskeyBourbon.
  ///
  /// In en, this message translates to:
  /// **'Bourbon'**
  String get subtype_whiskeyBourbon;

  /// No description provided for @subtype_whiskeyScotch.
  ///
  /// In en, this message translates to:
  /// **'Scotch'**
  String get subtype_whiskeyScotch;

  /// No description provided for @subtype_whiskeyFlavoured.
  ///
  /// In en, this message translates to:
  /// **'Flavoured'**
  String get subtype_whiskeyFlavoured;

  /// No description provided for @subtype_wineWhiteDry.
  ///
  /// In en, this message translates to:
  /// **'White — Dry'**
  String get subtype_wineWhiteDry;

  /// No description provided for @subtype_wineWhiteSemiDry.
  ///
  /// In en, this message translates to:
  /// **'White — Semi-dry'**
  String get subtype_wineWhiteSemiDry;

  /// No description provided for @subtype_wineWhiteSemiSweet.
  ///
  /// In en, this message translates to:
  /// **'White — Semi-sweet'**
  String get subtype_wineWhiteSemiSweet;

  /// No description provided for @subtype_wineWhiteSweet.
  ///
  /// In en, this message translates to:
  /// **'White — Sweet'**
  String get subtype_wineWhiteSweet;

  /// No description provided for @subtype_wineRoseDry.
  ///
  /// In en, this message translates to:
  /// **'Rosé — Dry'**
  String get subtype_wineRoseDry;

  /// No description provided for @subtype_wineRoseSemiDry.
  ///
  /// In en, this message translates to:
  /// **'Rosé — Semi-dry'**
  String get subtype_wineRoseSemiDry;

  /// No description provided for @subtype_wineRoseSemiSweet.
  ///
  /// In en, this message translates to:
  /// **'Rosé — Semi-sweet'**
  String get subtype_wineRoseSemiSweet;

  /// No description provided for @subtype_wineRedDry.
  ///
  /// In en, this message translates to:
  /// **'Red — Dry'**
  String get subtype_wineRedDry;

  /// No description provided for @subtype_wineRedSemiDry.
  ///
  /// In en, this message translates to:
  /// **'Red — Semi-dry'**
  String get subtype_wineRedSemiDry;

  /// No description provided for @subtype_wineRedSemiSweet.
  ///
  /// In en, this message translates to:
  /// **'Red — Semi-sweet'**
  String get subtype_wineRedSemiSweet;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['cs', 'de', 'en', 'sk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs': return AppLocalizationsCs();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'sk': return AppLocalizationsSk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
