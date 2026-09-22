import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/drink_type.dart';
import '../../core/utils/category_ui.dart';
import '../../l10n/app_localizations.dart';
import '../../models/drink_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  final Map<DrinkType, Map<String, dynamic>> _stats = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStats());
  }

  Future<void> _loadStats() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    for (final type in DrinkType.values) {
      final stats = await _firestoreService.getStats(userId, type);
      _stats[type] = stats;
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          loc.stats_title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              children: DrinkType.values.map((type) {
                return _CategoryStatsCard(
                  type: type,
                  label: categoryLabel(loc, type),
                  stats: _stats[type] ?? const {},
                  loc: loc,
                );
              }).toList(),
            ),
    );
  }
}

class _CategoryStatsCard extends StatelessWidget {
  final DrinkType type;
  final String label;
  final Map<String, dynamic> stats;
  final AppLocalizations loc;

  const _CategoryStatsCard({
    required this.type,
    required this.label,
    required this.stats,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final avgRating = stats['avgRating'] as double?;
    final bestDrink = stats['bestDrink'] as DrinkModel?;
    final mostExpensive = stats['mostExpensive'] as DrinkModel?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(type.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (avgRating == null)
            Text(
              loc.no_drinks,
              style: const TextStyle(color: AppColors.textSecondary),
            )
          else ...[
            _StatRow(
              icon: Icons.star_rounded,
              label: loc.stats_avg_rating,
              value: avgRating.toStringAsFixed(1),
            ),
            const SizedBox(height: 10),
            _StatRow(
              icon: Icons.emoji_events,
              label: loc.stats_best_drink,
              value: bestDrink != null
                  ? '${bestDrink.name} (${bestDrink.rating})'
                  : '—',
            ),
            const SizedBox(height: 10),
            _StatRow(
              icon: Icons.euro,
              label: loc.stats_most_expensive,
              value: mostExpensive != null
                  ? '${mostExpensive.name} (${mostExpensive.price!.toStringAsFixed(2)} ${mostExpensive.currency})'
                  : '—',
            ),
          ],
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
