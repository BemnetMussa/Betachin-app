import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/supabase_service.dart';
// Import Supabase package
import 'package:supabase_flutter/supabase_flutter.dart';

class PropertyDetailPage extends StatefulWidget {
  final int propertyId;

  const PropertyDetailPage({super.key, required this.propertyId});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  final SupabaseService _supabaseService = SupabaseService(
    supabase: Supabase.instance.client,
  );

  PropertyModel? _property;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _loadPropertyData();
  }

  Future<void> _loadPropertyData() async {
    setState(() => _isLoading = true);
    try {
      // Get the property details
      final properties = await _supabaseService.getProperties();
      final property = properties.firstWhere((p) => p.id == widget.propertyId);

      // Check if favorite
      final favorites = await _supabaseService.getUserFavorites();
      final isFavorite = favorites.contains(widget.propertyId);

      // Check if current user is the owner
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final isOwner = userId != null && userId == property.userId;

      if (mounted) {
        setState(() {
          _property = property;
          _isFavorite = isFavorite;
          _isOwner = isOwner;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading property: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      await _supabaseService.toggleFavorite(widget.propertyId);
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
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

  Future<void> _toggleListing() async {
    if (_property == null) return;

    try {
      await _supabaseService.togglePropertyListing(
        widget.propertyId,
        !_property!.isActive,
      );
      if (mounted) {
        setState(() {
          // Update the local property model
          _property = PropertyModel(
            id: _property!.id,
            userId: _property!.userId,
            propertyName: _property!.propertyName,
            address: _property!.address,
            floor: _property!.floor,
            city: _property!.city,
            bathrooms: _property!.bathrooms,
            bedrooms: _property!.bedrooms,
            squareFeet: _property!.squareFeet,
            price: _property!.price,
            description: _property!.description,
            type: _property!.type,
            listingType: _property!.listingType,
            rating: _property!.rating,
            createdAt: _property!.createdAt,
            isActive: !_property!.isActive,
            imageUrls: _property!.imageUrls,
            primaryImageUrl: _property!.primaryImageUrl,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _property!.isActive
                  ? 'Property listed successfully'
                  : 'Property delisted',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _navigateToEditProperty() {
    if (_property != null && mounted) {
      Navigator.pushNamed(
        context,
        '/edit_property',
        arguments: _property,
      ).then((_) => _loadPropertyData());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _property == null
              ? const Center(child: Text('Property not found'))
              : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        children: [
                          PageView.builder(
                            itemCount: _property!.imageUrls.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                _property!.imageUrls[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.home, size: 50),
                                  );
                                },
                              );
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    // Replace deprecated withOpacity with withValues
                                    Colors.black.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _property!.listingType == 'rent'
                                              ? Colors.green
                                              : Colors.blue,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _property!.listingType == 'rent'
                                          ? "For Rent"
                                          : "For Sale",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                        shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      _property!.rating.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                      if (_isOwner)
                        PopupMenuButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: const Text('Edit'),
                                  onTap: () {
                                    // Use a separate method to navigate after the menu closes
                                    Future.delayed(
                                      const Duration(milliseconds: 10),
                                      _navigateToEditProperty,
                                    );
                                  },
                                ),
                                PopupMenuItem(
                                  value:
                                      _property!.isActive ? 'delist' : 'list',
                                  onTap: _toggleListing,
                                  child: Text(
                                    _property!.isActive ? 'Delist' : 'List',
                                  ),
                                ),
                              ],
                        ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _property!.propertyName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '\$${_property!.price.toStringAsFixed(0)}${_property!.listingType == 'rent' ? '/night' : ''}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_property!.address}, ${_property!.city}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_property!.floor != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Floor: ${_property!.floor}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildFeatureItem(
                                Icons.bed,
                                '${_property!.bedrooms} ${_property!.bedrooms > 1 ? 'Bedrooms' : 'Bedroom'}',
                              ),
                              _buildFeatureItem(
                                Icons.bathtub_outlined,
                                '${_property!.bathrooms} ${_property!.bathrooms > 1 ? 'Bathrooms' : 'Bathroom'}',
                              ),
                              _buildFeatureItem(
                                Icons.crop_square,
                                '${_property!.squareFeet} sq ft',
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _property!.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Property Type',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _property!.type,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (!_isOwner)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              onPressed: () {
                                // Contact owner logic
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Contact request sent to owner',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Contact Owner'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
      ],
    );
  }
}
//property_detail page
