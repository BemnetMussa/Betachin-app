// File: lib/utils/favorites_manager.dart

import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const String _favoritesKey = 'favorites';

  // Add a property to favorites
  static Future<void> addFavorite(String propertyId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];
    if (!favorites.contains(propertyId)) {
      favorites.add(propertyId);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  // Remove a property from favorites
  static Future<void> removeFavorite(String propertyId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];
    favorites.remove(propertyId);
    await prefs.setStringList(_favoritesKey, favorites);
  }

  // Clear all favorites
  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }

  // Check if a property is a favorite
  static Future<bool> isFavorite(String propertyId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];
    return favorites.contains(propertyId);
  }

  // Get all favorite property IDs
  static Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }
}
