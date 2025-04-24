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
