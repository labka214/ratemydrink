import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums/drink_type.dart';

class DrinkModel {
  final String? id;
  final DrinkType type;
  final String name;
  final double rating;       // 0.5 – 5.0 (po pol-hviezdičke)
  final String? country;
  final String? manufacturer;
  final double? alcohol;
  final String? subtype;     // napr. "dark", "blond", "red"...
  final DateTime date;
  final String? url;
  final double? price;
  final String currency;
  final String? note;
  final String? imageUrl;
  final bool isFavorite;
  final DateTime createdAt;

  const DrinkModel({
    this.id,
    required this.type,
    required this.name,
    required this.rating,
    this.country,
    this.manufacturer,
    this.alcohol,
    this.subtype,
    required this.date,
    this.url,
    this.price,
    this.currency = 'EUR',
    this.note,
    this.imageUrl,
    this.isFavorite = false,
    required this.createdAt,
  });

  // Konverzia z Firestore dokumentu
  factory DrinkModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DrinkModel(
      id: doc.id,
      type: DrinkType.values.firstWhere(
        (e) => e.firestoreValue == data['type'],
        orElse: () => DrinkType.rum,
      ),
      name: data['name'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      country: data['country'],
      manufacturer: data['manufacturer'],
      alcohol: (data['alcohol'] as num?)?.toDouble(),
      subtype: data['subtype'],
      date: (data['date'] as Timestamp).toDate(),
      url: data['url'],
      price: (data['price'] as num?)?.toDouble(),
      currency: data['currency'] ?? 'EUR',
      note: data['note'],
      imageUrl: data['imageUrl'],
      isFavorite: data['isFavorite'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Konverzia do Firestore dokumentu
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.firestoreValue,
      'name': name,
      'rating': rating,
      'country': country,
      'manufacturer': manufacturer,
      'alcohol': alcohol,
      'subtype': subtype,
      'date': Timestamp.fromDate(date),
      'url': url,
      'price': price,
      'currency': currency,
      'note': note,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // CopyWith pre immutable aktualizácie
  DrinkModel copyWith({
    String? id,
    DrinkType? type,
    String? name,
    double? rating,
    String? country,
    String? manufacturer,
    double? alcohol,
    String? subtype,
    DateTime? date,
    String? url,
    double? price,
    String? currency,
    String? note,
    String? imageUrl,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return DrinkModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      country: country ?? this.country,
      manufacturer: manufacturer ?? this.manufacturer,
      alcohol: alcohol ?? this.alcohol,
      subtype: subtype ?? this.subtype,
      date: date ?? this.date,
      url: url ?? this.url,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      note: note ?? this.note,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}