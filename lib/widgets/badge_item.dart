import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/achievement.dart';

// Jedna bunka odznaku (kruh + názov + voliteľný progress bar) — zdieľaná
// medzi BadgesScreen (mriežka) a sekciou "Odznaky" v ProfileScreen
// (horizontálny scroll).
class BadgeItem extends StatelessWidget {
  final AchievementDefinition achievement;
  final bool isEarned;
  final int progress;
  final VoidCallback? onTap;
  final double circleSize;

  const BadgeItem({
    super.key,
    required this.achievement,
    required this.isEarned,
    required this.progress,
    this.onTap,
    this.circleSize = 72,
  });

  @override
  Widget build(BuildContext context) {
    final showProgress = !isEarned && achievement.targetCount != null;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEarned ? achievement.color : const Color(0xFF2A2A2A),
                  boxShadow: isEarned
                      ? [
                          BoxShadow(
                            color: achievement.color.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Opacity(
                    opacity: isEarned ? 1.0 : 0.35,
                    child: Text(
                      achievement.emoji,
                      style: TextStyle(fontSize: circleSize * 0.42),
                    ),
                  ),
                ),
              ),
              if (!isEarned)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1A1A1A),
                    ),
                    child:
                        const Icon(Icons.lock, size: 12, color: Colors.white38),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: circleSize + 16,
            child: Text(
              achievement.name,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showProgress) ...[
            const SizedBox(height: 4),
            Text(
              '$progress/${achievement.targetCount}',
              style: const TextStyle(fontSize: 9, color: Colors.white38),
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: circleSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: (progress / achievement.targetCount!).clamp(0.0, 1.0),
                  minHeight: 3,
                  backgroundColor: const Color(0xFF333333),
                  valueColor: AlwaysStoppedAnimation(
                    achievement.color.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
