import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  // Zachytí widget (RepaintBoundary) ako PNG a zdieľa ho.
  static Future<void> shareDrinkCard({
    required GlobalKey repaintKey,
    required String drinkName,
    String? text,
    double pixelRatio = 2.0,
  }) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Widget nie je renderovaný');
      }

      // Vykresli vo vysokom rozlíšení (pixelRatio 2.0 = 720px pri 360dp)
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // Uloží do dočasného súboru
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/ratemydrink_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      // Zdieľaj
      await Share.shareXFiles(
        [XFile(file.path)],
        text: text ?? 'Hodnotím $drinkName v RateMyDrink 🥃',
      );
    } catch (e) {
      debugPrint('ShareService error: $e');
      rethrow;
    }
  }
}
