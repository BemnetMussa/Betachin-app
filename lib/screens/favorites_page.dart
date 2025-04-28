// Import required packages for Flutter, Supabase, and custom utilities
import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/reusable/property_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../property/property_detail.dart'; // Adjust path as needed

// FavoritesPage widget, displays user-favorited properties
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

// State class for FavoritesPage, managing favorite properties and UI state
class _FavoritesPageState extends State<FavoritesPage> {
  // Initialize Supabase service for data operations
  final SupabaseService _supabaseService = SupabaseService(
    supabase: Supabase.instance.client,
  );

  // State variables for favorite properties and loading status
  List<PropertyModel> _favoriteProperties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load favorite properties on widget initialization
    _loadFavorites();
  }
  // Fetch favorite properties from Supabase
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
