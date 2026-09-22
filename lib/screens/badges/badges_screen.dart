import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/achievement.dart';
import '../../models/drink_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/achievement_definitions.dart';
import '../../services/achievement_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/badge_item.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  late final Future<List<DrinkModel>> _drinksFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final userId = context.read<AuthProvider>().userId;
    _drinksFuture = userId != null
        ? _firestoreService.getAllDrinksOnce(userId)
        : Future.value(const <DrinkModel>[]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showBadgeDetail(
    AppLocalizations loc,
    AchievementDefinition achievement,
    bool isEarned,
    int progress,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isEarned ? achievement.color : const Color(0xFF2A2A2A),
                    boxShadow: isEarned
                        ? [
                            BoxShadow(
                              color: achievement.color.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 3,
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: isEarned ? 1.0 : 0.35,
                      child: Text(
                        achievement.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  achievement.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (isEarned)
                  Text(
                    '${loc.badges_unlocked_label} ✓',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                else if (achievement.targetCount != null) ...[
                  Text(
                    '$progress / ${achievement.targetCount}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value:
                          (progress / achievement.targetCount!).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: const Color(0xFF333333),
                      valueColor: AlwaysStoppedAnimation(
                        achievement.color.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: FutureBuilder<List<DrinkModel>>(
          future: _drinksFuture,
          builder: (context, snapshot) {
            final drinks = snapshot.data ?? const <DrinkModel>[];
            final earned = AchievementService.calculateEarned(drinks);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.badges_title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  loc.badges_unlocked_count(
                    earned.length,
                    AchievementDefinitions.allAchievements.length,
                  ),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: loc.badges_tab_all),
            Tab(text: loc.category_rum),
            Tab(text: loc.category_whiskey),
            Tab(text: loc.badges_tab_other),
          ],
        ),
      ),
      body: FutureBuilder<List<DrinkModel>>(
        future: _drinksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final drinks = snapshot.data ?? const <DrinkModel>[];
          final earned = AchievementService.calculateEarned(drinks);

          return TabBarView(
            controller: _tabController,
            children: [
              _BadgeGrid(
                achievements: AchievementDefinitions.allAchievements,
                earned: earned,
                drinks: drinks,
                onTapBadge: (a, isEarned, progress) =>
                    _showBadgeDetail(loc, a, isEarned, progress),
              ),
              _BadgeGrid(
                achievements: AchievementDefinitions.rumAchievements,
                earned: earned,
                drinks: drinks,
                onTapBadge: (a, isEarned, progress) =>
                    _showBadgeDetail(loc, a, isEarned, progress),
              ),
              _BadgeGrid(
                achievements: AchievementDefinitions.whiskeyAchievements,
                earned: earned,
                drinks: drinks,
                onTapBadge: (a, isEarned, progress) =>
                    _showBadgeDetail(loc, a, isEarned, progress),
              ),
              _BadgeGrid(
                achievements: [
                  ...AchievementDefinitions.explorerAchievements,
                  ...AchievementDefinitions.collectorAchievements,
                  ...AchievementDefinitions.tasterAchievements,
                ],
                earned: earned,
                drinks: drinks,
                onTapBadge: (a, isEarned, progress) =>
                    _showBadgeDetail(loc, a, isEarned, progress),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  final List<AchievementDefinition> achievements;
  final Set<String> earned;
  final List<DrinkModel> drinks;
  final void Function(AchievementDefinition, bool isEarned, int progress)
      onTapBadge;

  const _BadgeGrid({
    required this.achievements,
    required this.earned,
    required this.drinks,
    required this.onTapBadge,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final isEarned = earned.contains(achievement.id);
        final progress = AchievementService.getProgress(drinks, achievement);
        return BadgeItem(
          achievement: achievement,
          isEarned: isEarned,
          progress: progress,
          onTap: () => onTapBadge(achievement, isEarned, progress),
        );
      },
    );
  }
}
