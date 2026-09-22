import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StarRatingWidget extends StatelessWidget {
  static const int _itemCount = 5;

  final double rating;
  final ValueChanged<double> onRatingUpdate;
  final double itemSize;
  final bool ignoreGestures;

  const StarRatingWidget({
    super.key,
    required this.rating,
    required this.onRatingUpdate,
    this.itemSize = 40.0,
    this.ignoreGestures = false,
  });

  void _handleTap(int index, double localDx) {
    final isFirstHalf = localDx < itemSize / 2;
    final value = index + (isFirstHalf ? 0.5 : 1.0);
    onRatingUpdate(value.clamp(0.5, _itemCount.toDouble()));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_itemCount, (index) {
        final starValue = index + 1;
        final IconData icon;
        if (rating >= starValue) {
          icon = Icons.star_rounded;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: ignoreGestures
              ? null
              : (details) => _handleTap(index, details.localPosition.dx),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              icon,
              size: itemSize,
              color: rating >= starValue - 0.5
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        );
      }),
    );
  }
}
