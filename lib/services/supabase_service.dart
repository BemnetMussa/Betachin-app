// lib/services/supabase_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property_model.dart';

class SupabaseService {
  final SupabaseClient supabase;

  SupabaseService({required this.supabase});

  // Get all properties
  Future<List<PropertyModel>> getProperties({
    bool rentOnly = false,
    bool buyOnly = false,
    String? searchQuery,
  }) async {
    var query = supabase
        .from('properties')
        .select('''
          *,
          property_images!inner(image_url)
        ''')
        .eq('is_active', true);

    if (rentOnly) {
      query = query.eq('listing_type', 'rent');
    } else if (buyOnly) {
      query = query.eq('listing_type', 'buy');
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or(
        'property_name.ilike.%$searchQuery%,address.ilike.%$searchQuery%,city.ilike.%$searchQuery%',
      );
    }

    try {
      final response = await query;

      final List<dynamic> data = response;

      // Process the data to format it correctly for our model
      List<PropertyModel> properties = [];

      // Group data by property id
      Map<int, Map<String, dynamic>> propertyMap = {};
      Map<int, List<String>> propertyImages = {};

      for (var item in data) {
        final propertyId = item['id'];
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
            'rating': item['rating'],
            'created_at': item['created_at'],
            'is_active': item['is_active'],
          };
          propertyImages[propertyId] = [];
        }

        if (item['property_images'] != null) {
          propertyImages[propertyId]!.add(item['property_images']['image_url']);
        }
      }

      // Convert to PropertyModel objects
      for (var propertyId in propertyMap.keys) {
        final Map<String, dynamic> property = propertyMap[propertyId]!;
        property['image_urls'] = propertyImages[propertyId] ?? [];
        property['primary_image_url'] =
            propertyImages[propertyId]?.isNotEmpty == true
                ? propertyImages[propertyId]![0]
                : '';

        properties.add(PropertyModel.fromJson(property));
      }

      return properties;
    } catch (e) {
      rethrow;
    }
  }

  // Get user's properties
  Future<List<PropertyModel>> getUserProperties() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return getProperties().then((allProperties) {
      return allProperties
          .where((property) => property.userId == userId)
          .toList();
    });
  }

  // Add a property
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
    required List<File> images,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // 1. Insert property data
      final propertyResponse =
          await supabase
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
              })
              .select()
              .single();

      final propertyId = propertyResponse['id'];
      List<String> imageUrls = [];

      // 2. Upload images and create records
      for (var i = 0; i < images.length; i++) {
        final file = images[i];
        final fileExt = file.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.$fileExt';
        final filePath = 'properties/$propertyId/$fileName';

        // Upload image to storage
        await supabase.storage.from('property_images').upload(filePath, file);

        // Get public URL
        final imageUrl = supabase.storage
            .from('property_images')
            .getPublicUrl(filePath);

        imageUrls.add(imageUrl);

        // Create image record
        await supabase.from('property_images').insert({
          'property_id': propertyId,
          'image_url': imageUrl,
          'is_primary': i == 0, // First image is primary
        });
      }

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
        createdAt: DateTime.now(),
        imageUrls: imageUrls,
        primaryImageUrl: imageUrls.isNotEmpty ? imageUrls[0] : '',
      );
    } catch (e) {
      rethrow;
    }
  }

  // Update a property
  Future<void> updateProperty({
    required int propertyId,
    String? propertyName,
    String? address,
    String? floor,
    String? city,
    int? bathrooms,
    int? bedrooms,
    int? squareFeet,
    double? price,
    String? description,
    String? type,
    String? listingType,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Verify ownership
      await supabase
          .from('properties')
          .select()
          .eq('id', propertyId)
          .eq('user_id', userId)
          .single();

      Map<String, dynamic> updates = {};
      if (propertyName != null) updates['property_name'] = propertyName;
      if (address != null) updates['address'] = address;
      if (floor != null) updates['floor'] = floor;
      if (city != null) updates['city'] = city;
      if (bathrooms != null) updates['bath_rooms'] = bathrooms;
      if (bedrooms != null) updates['bed_rooms'] = bedrooms;
      if (squareFeet != null) updates['square_feet'] = squareFeet;
      if (price != null) updates['price'] = price;
      if (description != null) updates['description'] = description;
      if (type != null) updates['type'] = type;
      if (listingType != null) updates['listing_type'] = listingType;

      if (updates.isNotEmpty) {
        await supabase.from('properties').update(updates).eq('id', propertyId);
      }
    } catch (e) {
      throw Exception('Property not found or you don\'t have permission');
    }
  }

  // Delist/Relist a property
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
      // 1. Verify ownership
      await supabase
          .from('properties')
          .select()
          .eq('id', propertyId)
          .eq('user_id', userId)
          .single();

      // 2. Delete the property (this will cascade delete images due to foreign key)
      await supabase.from('properties').delete().eq('id', propertyId);

      // 3. Delete images from storage
      try {
        await supabase.storage.from('property_images').remove([
          'properties/$propertyId/',
        ]);
      } catch (e) {
        // Continue even if storage deletion fails
        // Using logger instead of print for production code
        print('Failed to delete storage files: $e');
      }
    } catch (e) {
      throw Exception('Property not found or you don\'t have permission');
    }
  }

  // Toggle favorite
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
      rethrow;
    }
  }

  // Get user favorites
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
      rethrow;
    }
  }
}
