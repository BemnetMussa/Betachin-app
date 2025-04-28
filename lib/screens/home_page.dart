// Import required packages for Flutter, Supabase, and custom utilities
import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/reusable/property_card.dart';
import 'property_detail.dart';
import 'package:logging/logging.dart';
import './my_properties_page.dart'; // Import MyPropertiesPage
import './favorites_page.dart'; // Import FavoritesPage
import './profile_page.dart'; // Import ProfilePage

// HomePage widget, the main interface for property listings with navigation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// State class for HomePage, managing property data and UI state
class _HomePageState extends State<HomePage> {
  // Initialize Supabase service for data operations
  final SupabaseService _supabaseService = SupabaseService(
    supabase: Supabase.instance.client,
  );
  // Logger for debugging and error tracking
  final _logger = Logger('HomePage');

  // State variables for properties, favorites, and UI
  List<PropertyModel> _properties = [];
  List<int> _favoriteIds = [];
  bool _isLoading = true;
  bool _showRentOnly = false;
  bool _showBuyOnly = false;
  String _searchQuery = '';
  int _currentIndex = 0; // Track current navigation index

  @override
  void initState() {
    super.initState();
    // Load properties and favorites on widget initialization
    _loadData();
  }
  // Fetch properties and user favorites from Supabase
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
  // Toggle favorite status for a property
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