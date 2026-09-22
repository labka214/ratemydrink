import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Karta na zdieľanie hodnotenia. Vykresľuje sa mimo obrazovky (Offstage) pri
// logickej veľkosti 360×360dp a zachytáva sa cez
// RenderRepaintBoundary.toImage(pixelRatio: 3.0) → výsledný PNG má 1080×1080px.
class ShareCard extends StatelessWidget {
  final String drinkName;
  final String subtype; // preložený label
  final String? country;
  final String? manufacturer;
  final double rating; // 0.5 – 5.0
  final String? photoUrl;
  final String category; // 'rum' alebo 'whiskey'

  const ShareCard({
    super.key,
    required this.drinkName,
    required this.subtype,
    this.country,
    this.manufacturer,
    required this.rating,
    this.photoUrl,
    required this.category,
  });

  IconData get _categoryIcon =>
      category == 'whiskey' ? Icons.local_bar : Icons.liquor;

  String get _subtitleLine {
    final parts = [subtype, country ?? '']
        .where((s) => s.trim().isNotEmpty);
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      height: 360,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF2D1B00)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header — ikona + názov appky
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_bar, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'RateMyDrink',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Fotka alebo placeholder ikona
            _buildPhoto(),
            const SizedBox(height: 14),

            // Názov nápoja
            Text(
              drinkName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            // subtype · country
            if (_subtitleLine.isNotEmpty)
              Text(
                _subtitleLine,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
              ),
            // manufacturer
            if (manufacturer != null && manufacturer!.trim().isNotEmpty)
              Text(
                manufacturer!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
              ),
            const SizedBox(height: 12),

            // Hviezdičky + číslo hodnotenia
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(5, (index) {
                  final IconData icon;
                  if (index < rating.floor()) {
                    icon = Icons.star;
                  } else if (index < rating && rating % 1 >= 0.5) {
                    icon = Icons.star_half;
                  } else {
                    icon = Icons.star_border;
                  }
                  return Icon(icon, color: const Color(0xFFFFD700), size: 20);
                }),
                const SizedBox(width: 8),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Divider(color: Color(0x33FFFFFF), height: 1),
            const SizedBox(height: 10),

            const Text(
              'Objavené v RateMyDrink',
              style: TextStyle(color: Color(0xFF888888), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoto() {
    const size = 96.0;
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(_categoryIcon, size: 40, color: Colors.white),
    );

    if (photoUrl == null || photoUrl!.trim().isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: photoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      ),
    );
  }
}
