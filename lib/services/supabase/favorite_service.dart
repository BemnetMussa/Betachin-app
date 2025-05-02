import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/property_model.dart';

class FavoritesService {
  final SupabaseClient supabase;
  final _logger = Logger('FavoritesService');

  FavoritesService({required this.supabase});

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
      _logger.severe('Error toggling favorite: $e');
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
      _logger.severe('Error getting user favorites: $e');
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

   
}
