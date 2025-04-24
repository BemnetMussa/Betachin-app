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
