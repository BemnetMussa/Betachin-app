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
 Future<void> _logout() async {
    // Store the context before the async operation
    final navigatorContext = context;

    try {
      await Supabase.instance.client.auth.signOut();
 // Check if the widget is still mounted before using BuildContext
      if (!mounted) return;

      // Now it's safe to use the stored context after checking mounted
      Navigator.pushReplacementNamed(navigatorContext, '/login');
    } catch (e) {
      // Check if the widget is still mounted before using BuildContext
      if (!mounted) return;

      // Now it's safe to use the stored context after checking mounted
      ScaffoldMessenger.of(navigatorContext).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 0
            ? Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search properties...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  onSubmitted: (_) => _loadData(),
                ),
              )
            : Text(_currentIndex == 1
                ? 'Favorites'
                : _currentIndex == 2
                    ? 'My Properties'
                    : 'Profile'),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _loadData, // Just trigger search with current query
            ),
          TextButton(
            onPressed: _logout,
            child: const Text('Logout'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // Important for 4+ items
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_home), label: 'My Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
        floatingActionButton: _currentIndex == 0
          ? null
          : _currentIndex == 2
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/add_property',
                    ).then((_) {
                      // Refresh both My Properties and Home data
                      _loadData();
                      setState(() {});
                    });
                  },
                  tooltip: 'Add Property',
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }


  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempQuery = _searchQuery;
        return AlertDialog(
          title: const Text('Search Properties'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'Enter location, name, etc.',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => tempQuery = value,
            controller: TextEditingController(text: _searchQuery),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _searchQuery = tempQuery);
                _loadData();
                Navigator.pop(context);
              },
              child: const Text('SEARCH'),
            ),
          ],
        );
      },
    );
  }
}


