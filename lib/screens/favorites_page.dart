// lib/screens/favorites_page.dart
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final SupabaseService _supabaseService = SupabaseService(
    supabase: Supabase.instance.client,
  );

  List<PropertyModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      // Get favorite property IDs first
      final favoriteIds = await _supabaseService.getUserFavorites();

      // Then get all properties and filter for favorites
      final allProperties = await _supabaseService.getProperties();
      final favorites =
          allProperties
              .where((property) => favoriteIds.contains(property.id))
              .toList();

      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading favorites: ${e.toString()}')),
        );
      }
    }
  }
  Future<void> _toggleFavorite(int propertyId) async {
    try {
      await _supabaseService.toggleFavorite(propertyId);
      if (mounted) {
        setState(() {
          _favorites.removeWhere((property) => property.id == propertyId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _favorites.isEmpty
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No favorites yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Browse Properties'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadFavorites,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final property = _favorites[index];
                     return _buildPropertyCard(
                      id: property.id,
                      propertyName: property.propertyName,
                      address: "${property.address}, ${property.city}",
                      rating: property.rating,
                      price: property.price,
                      isRent: property.listingType == 'rent',
                      imageUrl: property.primaryImageUrl,
                      bedrooms: property.bedrooms,
                      bathrooms: property.bathrooms,
                      squareFeet: property.squareFeet,
                      isFavorite: true,
                      onFavoritePressed: () => _toggleFavorite(property.id),
                      onCardPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/property_detail',
                          arguments: property.id,
                        ).then((_) => _loadFavorites());
                      },
                    );
                  },
                ),
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            // Already on favorites page
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  // Method to build property card if the import is not available
  Widget _buildPropertyCard({
    required int id,
    required String propertyName,
    required String address,
    required num rating, // Change from double to num
    required double price,
    required bool isRent,
    required String imageUrl,
    required int bedrooms,
    required int bathrooms,
    required int squareFeet,
    required bool isFavorite,
    required VoidCallback onFavoritePressed,
    required VoidCallback onCardPressed,
  }) {
    return GestureDetector(
      onTap: onCardPressed,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: onFavoritePressed,
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                       ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isRent ? 'For Rent' : 'For Sale',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    propertyName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(address, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(rating.toString()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isRent
                        ? '\$${price.toStringAsFixed(0)}/month'
                        : '\$${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildFeature(Icons.bed, '$bedrooms Beds'),
                      const SizedBox(width: 16),
                      _buildFeature(Icons.bathtub, '$bathrooms Baths'),
                      const SizedBox(width: 16),
                      _buildFeature(
                        Icons.square_foot,
                        squareFeet.toStringAsFixed(0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
