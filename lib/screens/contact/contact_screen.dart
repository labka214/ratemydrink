import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontakt'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Support section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          color: Theme.of(context).colorScheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Podpora aplikácie',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'RateMyDrink je bezplatná aplikácia vyvíjaná vo voľnom čase. Ak ti pomáha sledovať tvoju zbierku rumov a whiskey, môžeš podporiť jej ďalší rozvoj.',
                    style: TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Replace with your actual support URL (Ko-fi, PayPal, etc.)
                        final uri = Uri.parse('https://ko-fi.com/ratemydrink');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.favorite_outline),
                      label: const Text('Podporiť vývoj'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Contact section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mail_outline,
                          color: Theme.of(context).colorScheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Napíšte nám',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Máte nápad na vylepšenie, narazili ste na chybu, alebo chcete pridať nápoj do databázy? Napíšte nám.',
                    style: TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri(
                          scheme: 'mailto',
                          path: 'ratemydrink@example.com', // Replace with real email
                          queryParameters: {
                            'subject': 'RateMyDrink – spätná väzba',
                          },
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('Odoslať správu'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // About section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'O aplikácii',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Verzia', value: '1.0.0'),
                  _InfoRow(label: 'Kategórie', value: 'Rum, Whiskey'),
                  _InfoRow(label: 'Databáza nápojov', value: '441 položiek'),
                  _InfoRow(label: 'Odznaky', value: '29 achievementov'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color)),
          ),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
