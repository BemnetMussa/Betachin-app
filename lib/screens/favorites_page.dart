// lib/screens/favorites/favorites_page.dart
import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/reusable/property_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './property_detail.dart'; // Adjust path as needed

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final SupabaseService _supabaseService = SupabaseService(
    supabase: Supabase.instance.client,
  );

  List<PropertyModel> _favoriteProperties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final properties = await _supabaseService.getFavoriteProperties();
      if (!mounted) return;
      setState(() {
        _favoriteProperties = properties;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading favorites: ${e.toString()}')),
      );
    }
  }

  Future<void> _toggleFavorite(int propertyId) async {
    try {
      await _supabaseService.toggleFavorite(propertyId);
      if (!mounted) return;
      // Remove the property from the list since it's no longer a favorite
      setState(() {
        _favoriteProperties
            .removeWhere((property) => property.id == propertyId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from favorites')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(0),
        ),

        // Main content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _favoriteProperties.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite_border,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No favorite properties',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Properties you favorite will appear here',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFavorites,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _favoriteProperties.length,
                        itemBuilder: (context, index) {
                          final property = _favoriteProperties[index];

                          return PropertyCard(
                            id: property.id,
                            propertyName: property.propertyName,
                            address: "${property.address}, ${property.city}",
                            rating: property.rating,
                            price: property.price,
                            isRent: property.listingType == 'rent',
                            imageUrl: property.primaryImageUrl ?? '',
                            bedrooms: property.bedrooms,
                            bathrooms: property.bathrooms,
                            squareFeet: property.squareFeet,
                            isFavorite: true,
                            onFavoritePressed: () =>
                                _toggleFavorite(property.id),
                            onCardPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PropertyDetailPage(
                                    propertyId: property.id,
                                  ),
                                ),
                              ).then((_) => _loadFavorites());
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
