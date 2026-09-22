import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/category_ui.dart';
import '../../models/drink_model.dart';

class DrinkCard extends StatelessWidget {
  final DrinkModel drink;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const DrinkCard({
    super.key,
    required this.drink,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Obrázok alebo placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: drink.imageUrl != null
                    ? Image.network(
                        drink.imageUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drink.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    RatingBarIndicator(
                      rating: drink.rating,
                      itemBuilder: (_, __) =>
                          const Icon(Icons.star_rounded, color: AppColors.star),
                      itemCount: 5,
                      itemSize: 15,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (drink.country != null) ...[
                          const Icon(Icons.location_on,
                              size: 11, color: AppColors.textSecondary),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              drink.country!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (drink.price != null)
                          Text(
                            '${drink.price!.toStringAsFixed(2)} ${drink.currency}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Obľúbené + dátum
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Icon(
                      drink.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: drink.isFavorite
                          ? AppColors.favorite
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${drink.date.day}.${drink.date.month}.${drink.date.year}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(categoryIcon(drink.type), color: AppColors.textSecondary),
    );
  }
}