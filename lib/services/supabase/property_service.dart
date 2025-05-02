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

  // Get a specific property by ID
  Future<PropertyModel> getPropertyById(int propertyId) async {
    try {
      final response = await supabase.from('properties').select('''
        *,
        property_images(image_url, is_primary)
      ''').eq('id', propertyId).single();

      // Process images
      List<String> imageUrls = [];
      String? primaryImageUrl;

      if (response['property_images'] != null) {
        final images = response['property_images'] as List;
        for (var image in images) {
          if (image != null && image['image_url'] != null) {
            imageUrls.add(image['image_url']);
            if (image['is_primary'] == true) {
              primaryImageUrl = image['image_url'];
            }
          }
        }
      }

      // If no primary image was marked, use the first one
      if (primaryImageUrl == null && imageUrls.isNotEmpty) {
        primaryImageUrl = imageUrls[0];
      }

      // Add images to property data
      Map<String, dynamic> propertyData = Map<String, dynamic>.from(response);
      propertyData['image_urls'] = imageUrls;
      propertyData['primary_image_url'] = primaryImageUrl;

      return PropertyModel.fromJson(propertyData);
    } catch (e) {
      _logger.severe('Error fetching property by ID: $e');
      rethrow;
    }
  }

  // Get users properties
  Future<List<PropertyModel>> getUserProperties() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Ensure token is valid
      if (supabase.auth.currentSession != null) {
        await supabase.auth.refreshSession();
      }

      var query = supabase.from('properties').select('''
        *,
        property_images(image_url, is_primary)
      ''').eq('user_id', userId).order('created_at', ascending: false);

      final response = await query;
      final List<dynamic> data = response;

      // Process the data to format it correctly for our model
      Map<int, Map<String, dynamic>> propertyMap = {};
      Map<int, List<Map<String, dynamic>>> propertyImages = {};

      for (var item in data) {
        final propertyId = item['id'] as int;

        // If we haven't seen this property before, create the base property data
        if (!propertyMap.containsKey(propertyId)) {
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
            'is_active':
                item['is_active'] ?? true, // Ensure is_active is properly set
          };
          propertyImages[propertyId] = [];
        }

        // Process property images
        if (item['property_images'] != null) {
          final images = item['property_images'] as List;
          for (var image in images) {
            if (image != null && image['image_url'] != null) {
              propertyImages[propertyId]!.add({
                'image_url': image['image_url'],
                'is_primary': image['is_primary'] ?? false,
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
        property['image_urls'] =
            imageData.map((img) => img['image_url'] as String).toList();

        // Find primary image or use the first one
        final primaryImageData = imageData.firstWhere(
          (img) => img['is_primary'] == true,
          orElse: () =>
              imageData.isNotEmpty ? imageData[0] : {'image_url': null},
        );

        property['primary_image_url'] = primaryImageData['image_url'];
        properties.add(PropertyModel.fromJson(property));
      }

      _logger.info('Retrieved ${properties.length} user properties');
      return properties;
    } catch (e) {
      _logger.severe('Error fetching user properties: $e');
      rethrow;
    }
  }
