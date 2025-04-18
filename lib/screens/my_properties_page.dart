// lib/screens/my_properties_page.dart
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/supabase_service.dart';
import '../utils/reusable/property_card.dart'; // Fixed path to match directory structure
import 'package:supabase_flutter/supabase_flutter.dart'; // Added Supabase import

class MyPropertiesPage extends StatefulWidget {
  const MyPropertiesPage({super.key}); // Using super parameter

  @override
  State<MyPropertiesPage> createState() => _MyPropertiesPageState();
}

class _MyPropertiesPageState extends State<MyPropertiesPage> {
  final SupabaseService _supabaseService = SupabaseService(
    supabase: Supabase.instance.client,
  );
  
  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadProperties();
  }
  
  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);
    try {
      final properties = await _supabaseService.getUserProperties();
      if (!mounted) return; // Check if widget is still mounted
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading properties: ${e.toString()}')),
      );
    }
  }
  
  void _showPropertyOptions(PropertyModel property) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Property'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context, 
                    '/edit_property',
                    arguments: property,
                  ).then((_) => _loadProperties());
                },
              ),
              ListTile(
                leading: Icon(
                  property.isActive ? Icons.visibility_off : Icons.visibility,
                ),
                title: Text(
                  property.isActive ? 'Delist Property' : 'List Property',
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _togglePropertyListing(property);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Property', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteProperty(property);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _togglePropertyListing(PropertyModel property) async {
    try {
      await _supabaseService.togglePropertyListing(property.id, !property.isActive);
      
      if (!mounted) return; // Check if widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            property.isActive 
                ? 'Property delisted successfully' 
                : 'Property listed successfully',
          ),
        ),
      );
      
      _loadProperties();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
  
  void _confirmDeleteProperty(PropertyModel property) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Property'),
          content: Text(
            'Are you sure you want to delete "${property.propertyName}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _supabaseService.deleteProperty(property.id);
                  
                  if (!mounted) return; // Check if widget is still mounted
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Property deleted successfully')),
                  );
                  
                  _loadProperties();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('DELETE', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Properties'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _properties.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.home_work, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'You have no properties',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/add_property')
                              .then((_) => _loadProperties());
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Property'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProperties,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _properties.length,
                    itemBuilder: (context, index) {
                      final property = _properties[index];
                      
                      return Stack(
                        children: [
                          PropertyCard(
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
                            isFavorite: false,
                            onCardPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/property_detail',
                                arguments: property.id,
                              ).then((_) => _loadProperties());
                            },
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: property.isActive 
                                    ? Colors.green
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                property.isActive ? 'Active' : 'Inactive',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: IconButton(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              onPressed: () => _showPropertyOptions(property),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_property')
              .then((_) => _loadProperties());
        },
        tooltip: 'Add Property',
        child: const Icon(Icons.add),
      ),
    );
  }
}

