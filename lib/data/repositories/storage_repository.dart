import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class StorageRepository {
  Future<String> uploadFile(File file, String path) async {
    try {
      await supabase.storage.from('workout_media').upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String publicUrl = supabase.storage.from('workout_media').getPublicUrl(path);
      
      return publicUrl;
    } catch (e) {
      print('Error uploading file to Supabase: $e');
      throw Exception('Error uploading file');
    }
  }
}