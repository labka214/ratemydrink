import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../home/main_shell.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  Future<void> _selectLanguage(BuildContext context, String locale) async {
    await context.read<SettingsProvider>().setLocale(locale);

    if (!context.mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.language, size: 60, color: AppColors.secondary),
            const SizedBox(height: 24),
            Text(
              'RateMyDrink',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 48),
            _LanguageButton(flag: '🇸🇰', label: 'Slovenčina', locale: 'sk', onTap: _selectLanguage),
            _LanguageButton(flag: '🇨🇿', label: 'Čeština',    locale: 'cs', onTap: _selectLanguage),
            _LanguageButton(flag: '🇬🇧', label: 'English',    locale: 'en', onTap: _selectLanguage),
            _LanguageButton(flag: '🇩🇪', label: 'Deutsch',    locale: 'de', onTap: _selectLanguage),
          ],
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String flag;
  final String label;
  final String locale;
  final Future<void> Function(BuildContext, String) onTap;

  const _LanguageButton({
    required this.flag,
    required this.label,
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 48),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => onTap(context, locale),
          child: Text(
            '$flag  $label',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}