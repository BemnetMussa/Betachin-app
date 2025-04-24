Future<void> _toggleFavorite(int propertyId) async {
    try {
      await _supabaseService.toggleFavorite(propertyId);
      if (mounted) {
        setState(() {
          if (_favoriteIds.contains(propertyId)) {
            _favoriteIds.remove(propertyId);
          } else {
            _favoriteIds.add(propertyId);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
 Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildFavoritesContent();
      case 2:
        return const MyPropertiesPage();
      case 3:
        return const ProfilePage(); // Add the profile page
      default:
        return _buildHomeContent();
    }
  }
Widget _buildHomeContent() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: !_showRentOnly && !_showBuyOnly,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _showRentOnly = false;
                            _showBuyOnly = false;
                          });
                          _loadData();
                        }
                      },
                    ),
                      const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('For Rent'),
                      selected: _showRentOnly,
                      onSelected: (selected) {
                        setState(() {
                          _showRentOnly = selected;
                          if (selected) {
                            _showBuyOnly = false;
                          }
                        });
                        _loadData();
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('For Sale'),
                      selected: _showBuyOnly,
                      onSelected: (selected) {
                        setState(() {
                          _showBuyOnly = selected;
                          if (selected) {
                            _showRentOnly = false;
                          }
                        });
                        _loadData();
                      },
                    ),
                  ],
                ),
              ),

                  Expanded(
                child: _properties.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.home_work,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No properties found',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                       : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _properties.length,
                          itemBuilder: (context, index) {
                            final property = _properties[index];
                            // Only show active properties in the home page
                            if (!property.isActive) {
                              return const SizedBox.shrink();
                            }
                            final isFavorite =
                                _favoriteIds.contains(property.id);
                            return PropertyCard(
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
                              isFavorite: isFavorite,
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
                                ).then((_) => _loadData());
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
}

  Widget _buildFavoritesContent() {
    return FutureBuilder<List<PropertyModel>>(
      future: _supabaseService.getFavoriteProperties(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No favorite properties',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        } else {
          final favoriteProperties = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Refresh to trigger rebuild
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteProperties.length,
              itemBuilder: (context, index) {
                final property = favoriteProperties[index];
                // Only show active properties in favorites too
                if (!property.isActive) {
                  return const SizedBox.shrink();
                }
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
                  onFavoritePressed: () {
                    _toggleFavorite(property.id);
                    setState(() {}); // Refresh to update UI
                  },
                  onCardPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PropertyDetailPage(
                          propertyId: property.id,
                        ),
                      ),
                    ).then((_) => setState(() {})); // Refresh after return
                  },
                );
              },
            ),
          );
        }
      },
    );
  }
