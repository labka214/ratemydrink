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

  /// No description provided for @category_whiskey.
  ///
  /// In en, this message translates to:
  /// **'Whiskey'**
  String get category_whiskey;

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

  /// No description provided for @manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Producer'**
  String get manufacturer;

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

  /// No description provided for @btn_pick_image.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get btn_pick_image;

  /// No description provided for @image_upload_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get image_upload_error;

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

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in and start rating'**
  String get login_subtitle;

  /// No description provided for @login_error.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get login_error;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @profile_logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profile_logout;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_tooltip.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get profile_tooltip;

  /// No description provided for @profile_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profile_name;

  /// No description provided for @profile_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profile_email;

  /// No description provided for @profile_phone.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get profile_phone;

  /// No description provided for @profile_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profile_save;

  /// No description provided for @profile_my_ratings.
  ///
  /// In en, this message translates to:
  /// **'My ratings'**
  String get profile_my_ratings;

  /// No description provided for @profile_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profile_language;

  /// No description provided for @support_title.
  ///
  /// In en, this message translates to:
  /// **'Support RateMyDrink'**
  String get support_title;

  /// No description provided for @support_thank_you.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using RateMyDrink! This app is free for everyone. Your donation helps cover the cost of cloud storage and keeps the app running.'**
  String get support_thank_you;

  /// No description provided for @support_description.
  ///
  /// In en, this message translates to:
  /// **'RateMyDrink is a free app developed in spare time with a passion for great drinks.'**
  String get support_description;

  /// No description provided for @support_visit_page.
  ///
  /// In en, this message translates to:
  /// **'Visit the project page'**
  String get support_visit_page;

  /// No description provided for @support_donate_2.
  ///
  /// In en, this message translates to:
  /// **'€2'**
  String get support_donate_2;

  /// No description provided for @support_donate_5.
  ///
  /// In en, this message translates to:
  /// **'€5'**
  String get support_donate_5;

  /// No description provided for @support_donate_10.
  ///
  /// In en, this message translates to:
  /// **'€10'**
  String get support_donate_10;

  /// No description provided for @support_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon — payment not configured yet'**
  String get support_coming_soon;

  /// No description provided for @support_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Support us'**
  String get support_tooltip;

  /// No description provided for @support_contact_title.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get support_contact_title;

  /// No description provided for @support_type_suggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get support_type_suggestion;

  /// No description provided for @support_type_bug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get support_type_bug;

  /// No description provided for @support_type_other.
  ///
  /// In en, this message translates to:
  /// **'Other message'**
  String get support_type_other;

  /// No description provided for @support_message_hint.
  ///
  /// In en, this message translates to:
  /// **'Your message...'**
  String get support_message_hint;

  /// No description provided for @support_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get support_send;

  /// No description provided for @support_message_sent.
  ///
  /// In en, this message translates to:
  /// **'Message sent, thank you!'**
  String get support_message_sent;

  /// No description provided for @export_csv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get export_csv;

  /// No description provided for @export_csv_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Export records (CSV)'**
  String get export_csv_tooltip;

  /// No description provided for @export_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to export data'**
  String get export_error;

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

  /// No description provided for @no_favorites.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet'**
  String get no_favorites;

  /// No description provided for @exit_app_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Exit app'**
  String get exit_app_tooltip;

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

  /// No description provided for @subtype_rumLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get subtype_rumLight;

  /// No description provided for @subtype_rumDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get subtype_rumDark;

  /// No description provided for @subtype_rumSpiced.
  ///
  /// In en, this message translates to:
  /// **'Spiced'**
  String get subtype_rumSpiced;

  /// No description provided for @subtype_rumAgricole.
  ///
  /// In en, this message translates to:
  /// **'Agricole'**
  String get subtype_rumAgricole;

  /// No description provided for @subtype_rumOverproof.
  ///
  /// In en, this message translates to:
  /// **'Overproof'**
  String get subtype_rumOverproof;

  /// No description provided for @subtype_whiskeyScotch.
  ///
  /// In en, this message translates to:
  /// **'Scotch'**
  String get subtype_whiskeyScotch;

  /// No description provided for @subtype_whiskeyIrish.
  ///
  /// In en, this message translates to:
  /// **'Irish'**
  String get subtype_whiskeyIrish;

  /// No description provided for @subtype_whiskeyBourbon.
  ///
  /// In en, this message translates to:
  /// **'Bourbon'**
  String get subtype_whiskeyBourbon;

  /// No description provided for @subtype_whiskeyJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get subtype_whiskeyJapanese;

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

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @navContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get navContact;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @leaderboard_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard_tooltip;

  /// No description provided for @leaderboard_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No ratings yet'**
  String get leaderboard_empty_title;

  /// No description provided for @leaderboard_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Add the first rum or whiskey!'**
  String get leaderboard_empty_subtitle;

  /// No description provided for @leaderboard_ratings.
  ///
  /// In en, this message translates to:
  /// **'{count} ratings'**
  String leaderboard_ratings(int count);

  /// No description provided for @leaderboard_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get leaderboard_error;

  /// No description provided for @share_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Share rating'**
  String get share_tooltip;

  /// No description provided for @share_error.
  ///
  /// In en, this message translates to:
  /// **'Sharing failed. Please try again.'**
  String get share_error;

  /// No description provided for @share_message.
  ///
  /// In en, this message translates to:
  /// **'Rating {name} on RateMyDrink 🥃'**
  String share_message(String name);

  /// No description provided for @share_preview_title.
  ///
  /// In en, this message translates to:
  /// **'Share card preview'**
  String get share_preview_title;

  /// No description provided for @share_button.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share_button;

  /// No description provided for @appearance_title.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance_title;

  /// No description provided for @theme_label.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme_label;

  /// No description provided for @theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get theme_light;

  /// No description provided for @theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get theme_system;

  /// No description provided for @theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get theme_dark;

  /// No description provided for @theme_light_note.
  ///
  /// In en, this message translates to:
  /// **'Light theme will be available in a future version'**
  String get theme_light_note;

  /// No description provided for @accent_color_label.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get accent_color_label;

  /// No description provided for @badges_title.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges_title;

  /// No description provided for @badges_unlocked_count.
  ///
  /// In en, this message translates to:
  /// **'{earned}/{total} unlocked'**
  String badges_unlocked_count(int earned, int total);

  /// No description provided for @badges_tab_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get badges_tab_all;

  /// No description provided for @badges_tab_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get badges_tab_other;

  /// No description provided for @badges_view_all.
  ///
  /// In en, this message translates to:
  /// **'View all →'**
  String get badges_view_all;

  /// No description provided for @badges_unlocked_label.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get badges_unlocked_label;
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
