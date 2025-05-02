import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/property_model.dart';
import 'storage_service.dart';

// Proper conditional imports
import 'dart:io' show File;
// Import only what we need from dart:html when on web
import 'package:universal_html/html.dart' as html
    if (dart.library.io) 'no_web.dart';

class PropertyService {
  final SupabaseClient supabase;
  final StorageService storageService;
  final _logger = Logger('PropertyService');

  PropertyService({required this.supabase, required this.storageService});

  Future<List<PropertyModel>> getProperties({
    bool rentOnly = false,
    bool buyOnly = false,
    String? searchQuery,
  }) async {
    try {
      var query = supabase.from('properties').select('''
        *,
        property_images(image_url, is_primary)
      ''').eq('is_active', true);

      // Apply listing type filters if specified
      if (rentOnly) {
        query = query.eq('listing_type', 'rent');
      } else if (buyOnly) {
        query = query.eq('listing_type', 'buy');
      }

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'property_name.ilike.%$searchQuery%,address.ilike.%$searchQuery%,city.ilike.%$searchQuery%',
        );
      }

      final response = await query;
      final List<dynamic> data = response;

      // Process the data to format it correctly for our model
      Map<int, Map<String, dynamic>> propertyMap = {};
      Map<int, List<Map<String, dynamic>>> propertyImages = {};

      for (var item in data) {
        final propertyId = item['id'] as int;

        // Create the base property data
        propertyMap[propertyId] = {
          'id': propertyId,
          'user_id': item['user_id'],
          'property_name': item['property_name'],
          'address': item['address'],
          'floor': item['floor'],
          'city': item['city'],
          'bath_rooms': item['bath_rooms'],
          'bed_rooms': item['bed_rooms'],
          'square_feet': item['square_feet'],
          'price': item['price'],
          'description': item['description'],
          'type': item['type'],
          'listing_type': item['listing_type'],
          'rating': item['rating'] ?? 0.0,
          'created_at': item['created_at'],
          'is_active': item['is_active'] ?? true,
        };

        // Process property images
        propertyImages[propertyId] = [];
        if (item['property_images'] != null) {
          final images = item['property_images'] as List;
          for (var image in images) {
            if (image != null && image['image_url'] != null) {
              final imageUrl = image['image_url'] as String;
              final isPrimary = image['is_primary'] ?? false;

              propertyImages[propertyId]!.add({
                'image_url': imageUrl,
                'is_primary': isPrimary,
              });
            }
          }
        }
      }

      // Convert to PropertyModel objects
      List<PropertyModel> properties = [];
      for (var propertyId in propertyMap.keys) {
        final Map<String, dynamic> property = propertyMap[propertyId]!;
        final imageData = propertyImages[propertyId] ?? [];

        // Add the image URLs to the property
        property['image_urls'] = imageData
            .where((img) => img['image_url'] != null)
            .map((img) => img['image_url'] as String)
            .toList();

        // Pick the primary image (prefer the one marked is_primary = true)
        final primaryImage = imageData.firstWhere(
          (img) => img['is_primary'] == true,
          orElse: () => {},
        );

        property['primary_image_url'] =
            primaryImage.isNotEmpty ? primaryImage['image_url'] : null;

        properties.add(PropertyModel.fromJson(property));
      }

      _logger.info('Fetched ${properties.length} properties');
      return properties;
    } catch (e) {
      _logger.severe('Error fetching properties: $e');
      rethrow;
    }
  }
}