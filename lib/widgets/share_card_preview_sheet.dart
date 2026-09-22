import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/share_service.dart';
import 'share_card.dart';

// Modálny bottom sheet s VIDITEĽNÝM náhľadom ShareCard — na rozdiel od
// predchádzajúceho Offstage prístupu je karta skutočne rozložená (laid out)
// na obrazovke, takže RepaintBoundary.toImage() má vždy platný RenderObject.
class ShareCardPreviewSheet extends StatefulWidget {
  final String drinkName;
  final String subtype;
  final String? country;
  final String? manufacturer;
  final double rating;
  final String? photoUrl;
  final String category;

  const ShareCardPreviewSheet({
    super.key,
    required this.drinkName,
    required this.subtype,
    this.country,
    this.manufacturer,
    required this.rating,
    this.photoUrl,
    required this.category,
  });

  @override
  State<ShareCardPreviewSheet> createState() => _ShareCardPreviewSheetState();
}

class _ShareCardPreviewSheetState extends State<ShareCardPreviewSheet> {
  final GlobalKey _shareKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _share(AppLocalizations loc) async {
    setState(() => _isSharing = true);
    try {
      await ShareService.shareDrinkCard(
        repaintKey: _shareKey,
        drinkName: widget.drinkName,
        text: loc.share_message(widget.drinkName),
        pixelRatio: 2.0,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.share_error)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.share_preview_title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              // Karta je tu naozaj rozložená (nie Offstage) — FittedBox ju
              // len vizuálne zmenší na užších obrazovkách; zachytený PNG má
              // stále natívnu veľkosť 360×360dp × pixelRatio.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: RepaintBoundary(
                    key: _shareKey,
                    child: ShareCard(
                      drinkName: widget.drinkName,
                      subtype: widget.subtype,
                      country: widget.country,
                      manufacturer: widget.manufacturer,
                      rating: widget.rating,
                      photoUrl: widget.photoUrl,
                      category: widget.category,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSharing ? null : () => _share(loc),
                  icon: _isSharing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : const Icon(Icons.share),
                  label: Text(loc.share_button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
