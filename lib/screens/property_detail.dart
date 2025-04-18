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
