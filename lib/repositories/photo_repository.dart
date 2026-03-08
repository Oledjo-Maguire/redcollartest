import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/photo.dart';

class PhotoRepository {
  static const String _photosKey = 'photos';

  Future<List<Photo>> getPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final photosJson = prefs.getStringList(_photosKey) ?? [];

    return photosJson
        .map((json) => Photo.fromJson(jsonDecode(json)))
        .where((photo) => File(photo.path).existsSync())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> savePhoto(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await imageFile.copy(path.join(appDir.path, fileName));

      final photo = Photo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        path: savedImage.path,
        createdAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      final photosJson = prefs.getStringList(_photosKey) ?? [];
      photosJson.add(jsonEncode(photo.toJson()));
      await prefs.setStringList(_photosKey, photosJson);
    } catch (e) {
      throw Exception('Failed to save photo: $e');
    }
  }

  Future<void> deletePhoto(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photosJson = prefs.getStringList(_photosKey) ?? [];

      final updatedPhotos = <String>[];
      for (var photoJson in photosJson) {
        final photo = Photo.fromJson(jsonDecode(photoJson));
        if (photo.id == id) {
          final file = File(photo.path);
          if (await file.exists()) {
            await file.delete();
          }
        } else {
          updatedPhotos.add(photoJson);
        }
      }

      await prefs.setStringList(_photosKey, updatedPhotos);
    } catch (e) {
      throw Exception('Failed to delete photo: $e');
    }
  }
}