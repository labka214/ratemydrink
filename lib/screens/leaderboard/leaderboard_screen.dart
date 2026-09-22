import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/drink_type.dart';
import '../../core/utils/category_ui.dart';
import '../../core/utils/subtype_ui.dart';
import '../../l10n/app_localizations.dart';
import '../../services/leaderboard_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: DrinkType.values.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text(
            loc.leaderboard,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.textSecondary),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: DrinkType.values.map((type) {
              return Tab(
                icon: Icon(categoryIcon(type)),
                text: categoryLabel(loc, type),
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: DrinkType.values.map((type) {
            return _LeaderboardTab(category: type.firestoreValue);
          }).toList(),
        ),
      ),
    );
  }
}

class _LeaderboardTab extends StatefulWidget {
  final String category;

  const _LeaderboardTab({required this.category});

  @override
  State<_LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<_LeaderboardTab> {
  late final Stream<List<LeaderboardEntry>> _stream;

  @override
  void initState() {
    super.initState();
    // Stream namiesto Future — rebríček sa prekreslí sám pri každej zmene
    // v `public_ratings`, takže sa vždy aktualizuje aj pri návrate na tab
    // (FutureBuilder by inak zobrazoval zastaraný jednorazový výsledok).
    _stream = LeaderboardService.watchTopDrinks(category: widget.category);
  }

  Future<void> _refresh() async {
    // Stream sa aktualizuje sám v reálnom čase — pull-to-refresh len
    // vynúti prekreslenie (napr. pre okamžitú vizuálnu odozvu).
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: _refresh,
      child: StreamBuilder<List<LeaderboardEntry>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Text(
                      loc.leaderboard_error,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            );
          }

          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.leaderboard_outlined,
                            size: 72,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            loc.leaderboard_empty_title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            loc.leaderboard_empty_subtitle,
                            textAlign: TextAlign.center,
                            style:
                                const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final rank = index + 1;
              return rank <= 3
                  ? _TopEntryCard(rank: rank, entry: entry, loc: loc)
                  : _RankListTile(rank: rank, entry: entry, loc: loc);
            },
          );
        },
      ),
    );
  }
}

String _subtitleLine(AppLocalizations loc, LeaderboardEntry entry) {
  final subtype = subtypeFromFirestoreValue(entry.subtype);
  final subtypeText =
      subtype != null ? subtypeLabel(loc, subtype) : entry.subtype;
  return [subtypeText, entry.country, entry.manufacturer]
      .where((s) => s.isNotEmpty)
      .join(' · ');
}

Color _rankColor(int rank) {
  switch (rank) {
    case 1:
      return const Color(0xFFFFD700);
    case 2:
      return const Color(0xFFC0C0C0);
    default:
      return const Color(0xFFCD7F32);
  }
}

class _StarsRow extends StatelessWidget {
  final double rating;
  final double size;

  const _StarsRow({required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final filled = rating.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < filled ? Icons.star : Icons.star_border,
          color: AppColors.star,
          size: size,
        );
      }),
    );
  }
}

class _TopEntryCard extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final AppLocalizations loc;

  const _TopEntryCard({
    required this.rank,
    required this.entry,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: _rankColor(rank), width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _rankColor(rank),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _subtitleLine(loc, entry),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _StarsRow(rating: entry.averageRating, size: 14),
              Text(
                '${entry.averageRating}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                loc.leaderboard_ratings(entry.ratingCount),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankListTile extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final AppLocalizations loc;

  const _RankListTile({
    required this.rank,
    required this.entry,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 32,
        child: Text(
          '$rank',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      title: Text(
        entry.name,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _subtitleLine(loc, entry),
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${entry.averageRating}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            loc.leaderboard_ratings(entry.ratingCount),
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
