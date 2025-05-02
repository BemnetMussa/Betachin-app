import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Proper conditional imports
import 'dart:io' show File;
// Import only what we need from dart:html when on web
import 'package:universal_html/html.dart' as html
    if (dart.library.io) 'no_web.dart';

class StorageService {
  final SupabaseClient supabase;
  final _logger = Logger('StorageService');

  StorageService({required this.supabase});

  // Upload a file from mobile
  Future<String> uploadFile(File file, String filePath) async {
    try {
      final fileExt = file.path.split('.').last;
      final filePathWithExt = '$filePath.$fileExt';
      _logger.info('Mobile upload: bucket=images, path=$filePathWithExt');

      await supabase.storage.from('images').upload(
            filePathWithExt,
            file,
          );

      final imageUrl =
          supabase.storage.from('images').getPublicUrl(filePathWithExt);
      _logger.info('Mobile image URL: $imageUrl');
      return imageUrl;
    } catch (e) {
      _logger.severe('Error uploading file: $e');
      rethrow;
    }
  }


}
