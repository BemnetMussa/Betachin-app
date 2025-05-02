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


   
}
