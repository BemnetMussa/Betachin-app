// File: lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import '../models/property.dart';
import '../utils/favorites_manager.dart';
import '../widgets/property_card.dart';
import '../widgets/app_drawer.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Property> _favoriteProperties = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favoriteIds = await FavoritesManager.getFavoriteIds();
    final allProperties = Property.getSampleProperties();
    setState(() {
      _favoriteProperties =
          allProperties
              .where((property) => favoriteIds.contains(property.id))
              .toList();
    });
  }

  Future<void> _clearFavorites() async {
    // Store the ScaffoldMessenger before the async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    await FavoritesManager.clearFavorites();
    setState(() {
      _favoriteProperties = [];
    });
    // Check if the widget is still mounted before using the context
    if (mounted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Cleared all favorites')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed:
                _favoriteProperties.isEmpty
                    ? null
                    : () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Clear All Favorites'),
                              content: const Text(
                                'Are you sure you want to remove all favorite properties?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _clearFavorites();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                      );
                    },
            tooltip: 'Clear All Favorites',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body:
          _favoriteProperties.isEmpty
              ? const Center(child: Text('No favorite properties yet.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _favoriteProperties.length,
                itemBuilder: (context, index) {
                  return PropertyCard(property: _favoriteProperties[index]);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadFavorites,
        tooltip: 'Refresh Favorites',
        child: const Icon(Icons.refresh), // Moved 'child' to the last argument
      ),
    );
  }
}
