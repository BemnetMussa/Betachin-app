import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property_model.dart';

// Proper conditional imports
import 'dart:io' show File;
// Import only what we need from dart:html when on web
import 'package:universal_html/html.dart' as html
    if (dart.library.io) 'no_web.dart';

class SupabaseService {
  final SupabaseClient supabase;
  final _logger = Logger('SupabaseService');

  SupabaseService({required this.supabase});

  // Refresh the authentication session to ensure the token is valid
  Future<void> refreshSession() async {
    try {
      if (supabase.auth.currentSession != null) {
        await supabase.auth.refreshSession();
        print('Session refreshed successfully');
      } else {
        print('No session to refresh');
      }
    } catch (e) {
      print('Error refreshing session: $e');
      _logger.severe('Error refreshing session: $e');
    }
  }

Future<List<PropertyModel>> getProperties({
  bool rentOnly = false,
  bool buyOnly = false,
  String? searchQuery,
}) async {
  try {
    var query = supabase.from('properties').select(''' 
      *,
      property_images(image_url, is_primary)
    ''');

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

    property['primary_image_url'] = primaryImage.isNotEmpty
        ? primaryImage['image_url']
        : null;


      property['primary_image_url'] = primaryImage != null
          ? primaryImage['image_url']
          : null;

      properties.add(PropertyModel.fromJson(property));
    }

    for (var property in properties) {
      print('Fetched property: ${property.propertyName}, Primary Image URL: ${property.primaryImageUrl}');
    }
    print('Fetched ${properties.length} properties');

    return properties;
  } catch (e) {
    print('Error fetching properties: $e');
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

  // Get user's properties
  Future<List<PropertyModel>> getUserProperties() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      var query = supabase.from('properties').select('''
        *,
        property_images(image_url, is_primary)
      ''').eq('user_id', userId);

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
            'is_active': item['is_active'] ?? true,
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
        property['image_urls'] = imageData.map((img) => img['image_url'] as String).toList();
        property['primary_image_url'] = imageData.firstWhere(
              (img) => img['is_primary'] == true,
              orElse: () => imageData.isNotEmpty ? imageData[0] : {'image_url': null},
            )['image_url'];

        properties.add(PropertyModel.fromJson(property));
      }

      return properties;
    } catch (e) {
      _logger.severe('Error fetching user properties: $e');
      rethrow;
    }
  }

  // Get favorite properties
  Future<List<PropertyModel>> getFavoriteProperties() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Get favorite IDs first
      final favoriteIds = await getUserFavorites();

      // If no favorites, return empty list early
      if (favoriteIds.isEmpty) {
        return [];
      }

      // Get all properties that match the favorite IDs
      var query = supabase.from('properties').select('''
        *,
        property_images(image_url, is_primary)
      ''').inFilter('id', favoriteIds);

      final response = await query;
      final List<dynamic> data = response;

      // Process the data
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
            'is_active': item['is_active'] ?? true,
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
        property['image_urls'] = imageData.map((img) => img['image_url'] as String).toList();
        property['primary_image_url'] = imageData.firstWhere(
              (img) => img['is_primary'] == true,
              orElse: () => imageData.isNotEmpty ? imageData[0] : {'image_url': null},
            )['image_url'];

        properties.add(PropertyModel.fromJson(property));
      }

      return properties;
    } catch (e) {
      _logger.severe('Error fetching favorite properties: $e');
      rethrow;
    }
  }

  // Add a property - updated with session refresh and detailed logging
  Future<PropertyModel> addProperty({
    required String propertyName,
    required String address,
    String? floor,
    required String city,
    required int bathrooms,
    required int bedrooms,
    required int squareFeet,
    required double price,
    required String description,
    required String type,
    required String listingType,
    required List<dynamic> images, // List<File> or List<html.File>
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      print('Adding property for user: $userId');
      print('Authentication state: ${supabase.auth.currentSession != null ? "Authenticated" : "Not Authenticated"}');
      print('Current session token: ${supabase.auth.currentSession?.accessToken.substring(0, 10)}...');
      await refreshSession(); // Ensure token is valid before upload

      // 1. Insert property data
      final propertyResponse = await supabase
          .from('properties')
          .insert({
            'user_id': userId,
            'property_name': propertyName,
            'address': address,
            'floor': floor,
            'city': city,
            'bath_rooms': bathrooms,
            'bed_rooms': bedrooms,
            'square_feet': squareFeet,
            'price': price,
            'description': description,
            'type': type,
            'listing_type': listingType,
            'is_active': true,
            'rating': 0.0,
          })
          .select()
          .single();

      final propertyId = propertyResponse['id'];
      print('Property inserted with ID: $propertyId');
      List<String> imageUrls = [];

      // 2. Upload images and create records
      for (var i = 0; i < images.length; i++) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i';
        final filePath = 'Property images/properties/$propertyId/$fileName';
        String imageUrl;

        print('Uploading image $i to path: $filePath');
        if (kIsWeb) {
          // Handle web file upload
          final file = images[i] as html.File;
          final bytes = await _readWebFileAsBytes(file);
          print('Web upload: bucket=images, path=$filePath, contentType=${file.type}');

          await supabase.storage.from('images').uploadBinary(
                filePath,
                bytes,
                fileOptions: FileOptions(contentType: file.type),
              );

          imageUrl = supabase.storage.from('images').getPublicUrl(filePath);
          print('Web image URL: $imageUrl');
        } else {
          // Handle native file upload
          final file = images[i] as File;
          final fileExt = file.path.split('.').last;
          final filePathWithExt = '$filePath.$fileExt';
          print('Mobile upload: bucket=images, path=$filePathWithExt');

          await supabase.storage.from('images').upload(
                filePathWithExt,
                file,
              );

          imageUrl = supabase.storage.from('images').getPublicUrl(filePathWithExt);
          print('Mobile image URL: $imageUrl');
        }

        imageUrls.add(imageUrl);
   
        // Create image record
        await supabase.from('property_images').insert({
          'property_id': propertyId,
          'image_url': imageUrl,
          'is_primary': i == 0, // First image is primary
        });
      }

      print('Property added with ${imageUrls.length} images');
      // 3. Return the newly created property with images
      return PropertyModel(
        id: propertyId,
        userId: userId,
        propertyName: propertyName,
        address: address,
        floor: floor,
        city: city,
        bathrooms: bathrooms,
        bedrooms: bedrooms,
        squareFeet: squareFeet,
        price: price,
        description: description,
        type: type,
        listingType: listingType,
        rating: 0.0,
        isActive: true,
        createdAt: DateTime.now(),
        imageUrls: imageUrls,
        primaryImageUrl: imageUrls.isNotEmpty ? imageUrls[0] : null,
      );
    } catch (e) {
      print('Error adding property: $e');
      _logger.severe('Error adding property: $e');
      rethrow;
    }
  }

  // Helper method to read web file as bytes
  Future<Uint8List> _readWebFileAsBytes(html.File file) {
    final completer = Completer<Uint8List>();
    final reader = html.FileReader();

    reader.onLoadEnd.listen((event) {
      final result = reader.result as Uint8List;
      completer.complete(result);
    });

    reader.readAsArrayBuffer(file);
    return completer.future;
  }

  // Updated update property method - fixed 'referrals' typo
  Future<void> updateProperty({
    required int propertyId,
    required String propertyName,
    required String address,
    String? floor,
    required String city,
    required int bathrooms,
    required int bedrooms,
    required int squareFeet,
    required double price,
    required String description,
    required String type,
    required String listingType,
    List<dynamic>? newImages,
    List<String>? imagesToDelete,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      print('Updating property ID: $propertyId for user: $userId');
      print('Authentication state: ${supabase.auth.currentSession != null ? "Authenticated" : "Not Authenticated"}');
      print('Current session token: ${supabase.auth.currentSession?.accessToken.substring(0, 10)}...');
      await refreshSession(); // Ensure token is valid before upload

      // Verify ownership
      await supabase
          .from('properties')
          .select()
          .eq('id', propertyId)
          .eq('user_id', userId)
          .single();

      // Handle image deletions if provided
      if (imagesToDelete != null && imagesToDelete.isNotEmpty) {
        for (final imageUrl in imagesToDelete) {
          print('Deleting image: $imageUrl');
          // Delete the image record from the database
          await supabase
              .from('property_images')
              .delete()
              .eq('image_url', imageUrl)
              .eq('property_id', propertyId);

          // Extract the file path from the URL to delete from storage
          try {
            final regex = RegExp(r'images\/(.+)');
            final match = regex.firstMatch(imageUrl);
            if (match != null && match.groupCount >= 1) {
              final storagePath = match.group(1);
              if (storagePath != null) {
                print('Removing from storage: $storagePath');
                await supabase.storage.from('images').remove([storagePath]);
              }
            }
          } catch (e) {
            _logger.warning('Failed to delete image from storage: $e');
            // Continue with the rest of the operation even if storage deletion fails
          }
        }
      }

      // Handle new image uploads if provided
      if (newImages != null && newImages.isNotEmpty) {
        for (var i = 0; i < newImages.length; i++) {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i';
          final filePath = 'Property images/properties/$propertyId/$fileName';
          String imageUrl;

          print('Uploading new image $i to path: $filePath');
          if (kIsWeb) {
            // Handle web file upload
            final file = newImages[i] as html.File;
            final bytes = await _readWebFileAsBytes(file);
            print('Web upload: bucket=images, path=$filePath, contentType=${file.type}');

            await supabase.storage.from('images').uploadBinary(
                  filePath,
                  bytes,
                  fileOptions: FileOptions(contentType: file.type),
                );

            imageUrl = supabase.storage.from('images').getPublicUrl(filePath);
            print('Web image URL: $imageUrl');
          } else {
            // Handle native file upload
            final file = newImages[i] as File;
            final fileExt = file.path.split('.').last;
            final filePathWithExt = '$filePath.$fileExt';
            print('Mobile upload: bucket=images, path=$filePathWithExt');

            await supabase.storage.from('images').upload(
                  filePathWithExt,
                  file,
                );

            imageUrl = supabase.storage.from('images').getPublicUrl(filePathWithExt);
            print('Mobile image URL: $imageUrl');
          }

          print('Inserting new image URL into property_images: $imageUrl');
          // Create new image record
          await supabase.from('property_images').insert({
            'property_id': propertyId,
            'image_url': imageUrl,
            'is_primary': false, // New uploads are not primary by default
          });
        }
      }

      // Update the property data
      Map<String, dynamic> updates = {
        'property_name': propertyName,
        'address': address,
        'floor': floor,
        'city': city,
        'bath_rooms': bathrooms,
        'bed_rooms': bedrooms,
        'square_feet': squareFeet,
        'price': price,
        'description': description,
        'type': type,
        'listing_type': listingType,
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('Updating property data with: $updates');
      await supabase.from('properties').update(updates).eq('id', propertyId);
      print('Property updated successfully');
    } catch (e) {
      print('Error updating property: $e');
      _logger.severe('Error updating property: $e');
      throw Exception('Failed to update property: $e');
    }
  }

  // Toggle property listing status - used in MyPropertiesPage
  Future<void> togglePropertyListing(int propertyId, bool isActive) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await supabase
          .from('properties')
          .update({'is_active': isActive})
          .eq('id', propertyId)
          .eq('user_id', userId);
    } catch (e) {
      _logger.severe('Error toggling property listing: $e');
      rethrow;
    }
  }

  // Delete a property
  Future<void> deleteProperty(int propertyId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      print('Deleting property ID: $propertyId for user: $userId');
      print('Authentication state: ${supabase.auth.currentSession != null ? "Authenticated" : "Not Authenticated"}');
      print('Current session token: ${supabase.auth.currentSession?.accessToken.substring(0, 10)}...');
      await refreshSession();

      // 1. Verify ownership
      await supabase
          .from('properties')
          .select()
          .eq('id', propertyId)
          .eq('user_id', userId)
          .single();

      // 2. Get all image URLs for this property
      final imageResponse = await supabase
          .from('property_images')
          .select('image_url')
          .eq('property_id', propertyId);

      final List<dynamic> imageData = imageResponse;
      final List<String> imagePaths = [];

      // Extract storage paths from URLs
      for (var item in imageData) {
        final imageUrl = item['image_url'] as String;
        final regex = RegExp(r'images\/(.+)');
        final match = regex.firstMatch(imageUrl);
        if (match != null && match.groupCount >= 1) {
          final storagePath = match.group(1);
          if (storagePath != null) {
            imagePaths.add(storagePath);
          }
        }
      }

      // 3. Delete all property images from storage
      if (imagePaths.isNotEmpty) {
        try {
          print('Removing images from storage: $imagePaths');
          await supabase.storage.from('images').remove(imagePaths);
        } catch (e) {
          // Continue even if storage deletion fails
          _logger.warning('Failed to delete some storage files: $e');
        }
      }

      // 4. Delete property records (cascade will delete property_images entries)
      print('Deleting property records for property ID: $propertyId');
      await supabase.from('properties').delete().eq('id', propertyId);
      print('Property deleted successfully');
    } catch (e) {
      print('Error deleting property: $e');
      _logger.severe('Error deleting property: $e');
      throw Exception('Property not found or you don\'t have permission: $e');
    }
  }

  // Toggle favorite - used in HomePage
  Future<void> toggleFavorite(int propertyId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Check if already favorited
      final existingFav = await supabase
          .from('favorites')
          .select()
          .eq('property_id', propertyId)
          .eq('user_id', userId);

      if ((existingFav as List).isEmpty) {
        // Add to favorites
        await supabase.from('favorites').insert({
          'property_id': propertyId,
          'user_id': userId,
        });
      } else {
        // Remove from favorites
        await supabase
            .from('favorites')
            .delete()
            .eq('property_id', propertyId)
            .eq('user_id', userId);
      }
    } catch (e) {
      _logger.severe('Error toggling favorite: $e');
      rethrow;
    }
  }

  // Get user favorites - used in HomePage
  Future<List<int>> getUserFavorites() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await supabase
          .from('favorites')
          .select('property_id')
          .eq('user_id', userId);

      final List<dynamic> data = response;
      return data.map<int>((item) => item['property_id'] as int).toList();
    } catch (e) {
      _logger.severe('Error getting user favorites: $e');
      rethrow;
    }
  }

  // Get user profile details
  Future<Map<String, dynamic>> getUserProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response =
          await supabase.from('profiles').select().eq('id', userId).single();

      return response;
    } catch (e) {
      _logger.severe('Error getting user profile: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String fullName,
    String? avatarUrl,
    String? phone,
    String? address,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await supabase.from('profiles').update({
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'phone': phone,
        'address': address,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      _logger.severe('Error updating user profile: $e');
      rethrow;
    }
  }
}