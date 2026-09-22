import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/drinks_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('locale') ?? 'en';

  runApp(RateMyDrinkApp(savedLocale: savedLocale));
}

class RateMyDrinkApp extends StatelessWidget {
  final String? savedLocale;

  const RateMyDrinkApp({super.key, this.savedLocale});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DrinksProvider()),
        ChangeNotifierProxyProvider<DrinksProvider, AuthProvider>(
          create: (_) => AuthProvider(),
          update: (_, drinksProvider, authProvider) =>
              (authProvider ?? AuthProvider())
                ..attachDrinksProvider(drinksProvider),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SettingsProvider(initialLocale: savedLocale)..loadSettings(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'RateMyDrink',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('sk'),
            Locale('cs'),
            Locale('en'),
            Locale('de'),
          ],
          locale: settings.locale,
          themeMode: settings.themeMode,
          theme: AppTheme.light(settings.accentColor),
          darkTheme: AppTheme.dark(settings.accentColor),
          home: SplashScreen(savedLocale: savedLocale),
        ),
      ),
    );
  }
}
