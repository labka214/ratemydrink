import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/constants/app_colors.dart';

class StarRatingWidget extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 0.5,
      maxRating: 5,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: itemSize,
      ignoreGestures: ignoreGestures,
      itemBuilder: (context, _) => const Icon(
        Icons.star_rounded,
        color: AppColors.primary,
      ),
      unratedColor: AppColors.surface,
      onRatingUpdate: onRatingUpdate,
    );
  }
}