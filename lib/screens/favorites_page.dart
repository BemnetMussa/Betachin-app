Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final properties = await _supabaseService.getProperties(
        rentOnly: _showRentOnly,
        buyOnly: _showBuyOnly,
        searchQuery: _searchQuery,
      );
      final favorites = await _supabaseService.getUserFavorites();
      if (mounted) {
        setState(() {
          _properties = properties;
          _favoriteIds = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading properties: ${e.toString()}')),
        );
      }
    }
  }
