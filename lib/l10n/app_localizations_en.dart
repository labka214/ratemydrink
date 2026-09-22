// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'RateMyDrink';

  @override
  String get select_language => 'Select language';

  @override
  String get category_rum => 'Rum';

  @override
  String get category_whiskey => 'Whiskey';

  @override
  String get btn_save => 'Save';

  @override
  String get btn_cancel => 'Cancel';

  @override
  String get btn_edit => 'Edit';

  @override
  String get btn_delete => 'Delete';

  @override
  String get btn_add => 'Add';

  @override
  String get btn_filter => 'Filter';

  @override
  String get btn_back => 'Back';

  @override
  String get field_name => 'Name';

  @override
  String get field_rating => 'Rating';

  @override
  String get field_country => 'Country';

  @override
  String get manufacturer => 'Producer';

  @override
  String get field_alcohol => 'Alcohol (%)';

  @override
  String get field_subtype => 'Type';

  @override
  String get field_date => 'Date';

  @override
  String get field_url => 'URL';

  @override
  String get field_price => 'Price';

  @override
  String get field_note => 'Note';

  @override
  String get field_image => 'Image';

  @override
  String get btn_pick_image => 'Choose photo';

  @override
  String get image_upload_error => 'Failed to upload image';

  @override
  String get field_currency => 'Currency';

  @override
  String get validation_required => 'This field is required';

  @override
  String get validation_number => 'Enter a valid number';

  @override
  String get login_google => 'Sign in with Google';

  @override
  String get login_subtitle => 'Sign in and start rating';

  @override
  String get login_error => 'Sign-in failed. Please try again.';

  @override
  String get logout => 'Sign out';

  @override
  String get profile_logout => 'Sign out';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_tooltip => 'View profile';

  @override
  String get profile_name => 'Name';

  @override
  String get profile_email => 'Email';

  @override
  String get profile_phone => 'Mobile';

  @override
  String get profile_save => 'Save';

  @override
  String get profile_my_ratings => 'My ratings';

  @override
  String get profile_language => 'Language';

  @override
  String get support_title => 'Support RateMyDrink';

  @override
  String get support_thank_you => 'Thank you for using RateMyDrink! This app is free for everyone. Your donation helps cover the cost of cloud storage and keeps the app running.';

  @override
  String get support_donate_2 => '€2';

  @override
  String get support_donate_5 => '€5';

  @override
  String get support_donate_10 => '€10';

  @override
  String get support_coming_soon => 'Coming soon — payment not configured yet';

  @override
  String get support_tooltip => 'Support us';

  @override
  String get support_contact_title => 'Contact us';

  @override
  String get support_type_suggestion => 'Suggestion';

  @override
  String get support_type_bug => 'Bug';

  @override
  String get support_type_other => 'Other message';

  @override
  String get support_message_hint => 'Your message...';

  @override
  String get support_send => 'Send';

  @override
  String get support_message_sent => 'Message sent, thank you!';

  @override
  String get export_csv => 'Export CSV';

  @override
  String get export_csv_tooltip => 'Export records (CSV)';

  @override
  String get export_error => 'Failed to export data';

  @override
  String get stats_title => 'Statistics';

  @override
  String get stats_avg_rating => 'Average rating';

  @override
  String get stats_best_drink => 'Best drink';

  @override
  String get stats_most_expensive => 'Most expensive drink';

  @override
  String get filter_rating_high => 'Rating: highest';

  @override
  String get filter_rating_low => 'Rating: lowest';

  @override
  String get filter_price_high => 'Price: highest';

  @override
  String get filter_price_low => 'Price: lowest';

  @override
  String get filter_date_new => 'Date: newest';

  @override
  String get filter_date_old => 'Date: oldest';

  @override
  String get favorites => 'Favourites';

  @override
  String get no_favorites => 'No favourites yet';

  @override
  String get exit_app_tooltip => 'Exit app';

  @override
  String get no_drinks => 'No records';

  @override
  String get search_hint => 'Search by name...';

  @override
  String get subtype_rumLight => 'Light';

  @override
  String get subtype_rumDark => 'Dark';

  @override
  String get subtype_rumSpiced => 'Spiced';

  @override
  String get subtype_rumAgricole => 'Agricole';

  @override
  String get subtype_rumOverproof => 'Overproof';

  @override
  String get subtype_whiskeyScotch => 'Scotch';

  @override
  String get subtype_whiskeyIrish => 'Irish';

  @override
  String get subtype_whiskeyBourbon => 'Bourbon';

  @override
  String get subtype_whiskeyJapanese => 'Japanese';

  @override
  String get subtype_whiskeySingleMalt => 'Single Malt';

  @override
  String get subtype_whiskeyBlended => 'Blended';

  @override
  String get nav_home => 'Home';

  @override
  String get navContact => 'Contact';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get leaderboard_tooltip => 'Leaderboard';

  @override
  String get leaderboard_empty_title => 'No ratings yet';

  @override
  String get leaderboard_empty_subtitle => 'Add the first rum or whiskey!';

  @override
  String leaderboard_ratings(int count) {
    return '$count ratings';
  }

  @override
  String get leaderboard_error => 'Failed to load';

  @override
  String get share_tooltip => 'Share rating';

  @override
  String get share_error => 'Sharing failed. Please try again.';

  @override
  String share_message(String name) {
    return 'Rating $name on RateMyDrink 🥃';
  }

  @override
  String get share_preview_title => 'Share card preview';

  @override
  String get share_button => 'Share';

  @override
  String get appearance_title => 'Appearance';

  @override
  String get theme_label => 'Theme';

  @override
  String get theme_light => 'Light';

  @override
  String get theme_system => 'System';

  @override
  String get theme_dark => 'Dark';

  @override
  String get theme_light_note => 'Light theme will be available in a future version';

  @override
  String get accent_color_label => 'Color';

  @override
  String get badges_title => 'Badges';

  @override
  String badges_unlocked_count(int earned, int total) {
    return '$earned/$total unlocked';
  }

  @override
  String get badges_tab_all => 'All';

  @override
  String get badges_tab_other => 'Other';

  @override
  String get badges_view_all => 'View all →';

  @override
  String get badges_unlocked_label => 'Unlocked';
}
