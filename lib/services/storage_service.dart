import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Reference _drinkImageRef(String userId, String drinkId) {
    return _storage.ref().child('users/$userId/drinks/$drinkId.jpg');
  }

  // Nahraj fotku nápoja a vráť download URL
  Future<String> uploadDrinkImage(
    String userId,
    String drinkId,
    File imageFile,
  ) async {
    final ref = _drinkImageRef(userId, drinkId);
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    // Zmenši na max 500px na dlhšej strane a komprimuj na JPEG kvalitu 60
    final compressed = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      minWidth: 500,
      minHeight: 500,
      quality: 60,
      format: CompressFormat.jpeg,
    );

    final uploadTask = compressed != null
        ? ref.putData(compressed, metadata)
        : ref.putFile(imageFile, metadata);
    await uploadTask;

    return await ref.getDownloadURL();
  }

  // Vymaž fotku nápoja (ak existuje)
  Future<void> deleteDrinkImage(String userId, String drinkId) async {
    try {
      await _drinkImageRef(userId, drinkId).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }
}
