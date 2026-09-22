import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/utils/subtype_ui.dart';
import '../models/drink_model.dart';

class ExportService {
  static const List<String> _headers = [
    'name',
    'rating',
    'country',
    'alcohol%',
    'subtype',
    'date',
    'price',
    'currency',
    'note',
    'url',
  ];

  // Exportuj zoznam nápojov (jedna kategória alebo všetky) do CSV a otvor share sheet
  Future<void> exportDrinks({
    required List<DrinkModel> drinks,
    required String fileName,
    String? shareText,
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd');

    final rows = <List<dynamic>>[
      _headers,
      ...drinks.map((d) => [
            d.name,
            d.rating,
            d.country ?? '',
            d.alcohol ?? '',
            _subtypeLabel(d.subtype),
            dateFormat.format(d.date),
            d.price ?? '',
            d.currency,
            d.note ?? '',
            d.url ?? '',
          ]),
    ];

    final csvData = const ListToCsvConverter().convert(rows);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName.csv');
    await file.writeAsString(csvData);

    await Share.shareXFiles([XFile(file.path)], text: shareText);
  }

  // Konvertuj firestoreValue podkategórie na čitateľný text (anglický názov,
  // keďže CSV export nemá prístup k lokalizačnému kontextu).
  String _subtypeLabel(String? firestoreValue) {
    final subtype = subtypeFromFirestoreValue(firestoreValue);
    return subtype?.name ?? firestoreValue ?? '';
  }
}
